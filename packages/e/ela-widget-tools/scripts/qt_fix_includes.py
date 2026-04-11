# -*- coding: utf-8 -*-
import os
import re
import shutil
import argparse
from typing import List, Set, Tuple
import sys
try: 
    sys.stdout.reconfigure(encoding='utf-8')
except:
    pass

# 配置：需要自动补全的Qt类及其对应的头文件
# 格式: { "类名": "头文件名" }
QT_CLASS_INCLUDES = {
    "QVariant": "QVariant",
    # "QString": "QString",
    # "QList": "QList",
    # "QVector": "QVector",
    # "QMap": "QMap",
    # "QHash": "QHash",
    # "QDateTime": "QDateTime",
    "QDate": "QDate",
    # "QTime": "QTime",
    # "QFile": "QFile",
    # "QDir": "QDir",
    # "QUrl": "QUrl",
    # "QJsonDocument": "QJsonDocument",
    # "QJsonObject": "QJsonObject",
    # "QJsonArray": "QJsonArray",
    "QVariantMap": "QVariantMap",
    "QImage": "QImage",

}

# 正则表达式模式
# 匹配#include语句（支持<>和""两种形式）
INCLUDE_PATTERN = re.compile(r'^\s*#\s*include\s*[<"]([^>"]+)[>"]\s*$', re.MULTILINE)
# 匹配单行注释
LINE_COMMENT_PATTERN = re.compile(r'//.*$', re.MULTILINE)
# 匹配多行注释
BLOCK_COMMENT_PATTERN = re.compile(r'/\*.*?\*/', re.DOTALL)
# 匹配字符串字面量
STRING_PATTERN = re.compile(r'"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', re.DOTALL)


def remove_comments_and_strings(content: str) -> str:
    """移除代码中的注释和字符串，只保留纯代码部分用于检测类使用"""
    # 先移除多行注释
    content = BLOCK_COMMENT_PATTERN.sub('', content)
    # 再移除单行注释
    content = LINE_COMMENT_PATTERN.sub('', content)
    # 最后移除字符串字面量
    content = STRING_PATTERN.sub('', content)
    return content


def get_existing_includes(content: str) -> Set[str]:
    """获取文件中已经包含的所有头文件"""
    includes = set()
    for match in INCLUDE_PATTERN.finditer(content):
        includes.add(match.group(1))
    return includes


def find_best_insert_position(content: str) -> int:
    """找到插入新#include的最佳位置（在现有#include块的末尾）"""
    matches = list(INCLUDE_PATTERN.finditer(content))
    if not matches:
        # 如果没有任何#include，插入到文件开头
        return 0
    
    # 返回最后一个#include语句的结束位置
    return matches[-1].end()


def process_file(file_path: str, dry_run: bool = False, no_backup: bool = False) -> bool:
    """处理单个文件，返回是否有修改"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except UnicodeDecodeError:
        # 尝试用GBK编码读取（Windows下常见）
        try:
            with open(file_path, 'r', encoding='gbk') as f:
                content = f.read()
        except Exception as e:
            print(f"❌ 无法读取文件 {file_path}: {e}")
            return False
    
    # 获取现有包含的头文件
    existing_includes = get_existing_includes(content)
    
    # 移除注释和字符串，只保留纯代码
    pure_code = remove_comments_and_strings(content)
    
    # 检查需要添加哪些头文件
    includes_to_add: List[str] = []
    for class_name, header_name in QT_CLASS_INCLUDES.items():
        # 检查代码中是否使用了该类（作为独立单词出现）
        if re.search(r'\b' + re.escape(class_name) + r'\b', pure_code):
            if header_name not in existing_includes:
                includes_to_add.append(header_name)
    
    if not includes_to_add:
        return False
    
    # 打印要修改的信息
    print(f"📄 {file_path}")
    for header in includes_to_add:
        print(f"  + 添加 #include <{header}>")
    
    if dry_run:
        return True
    
    # 备份原文件
    if not no_backup:
        backup_path = file_path + '.bak'
        shutil.copy2(file_path, backup_path)
    
    # 找到插入位置
    insert_pos = find_best_insert_position(content)
    
    # 生成要插入的内容
    insert_content = '\n' + '\n'.join([f'#include <{header}>' for header in includes_to_add]) + '\n'
    
    # 插入内容
    new_content = content[:insert_pos] + insert_content + content[insert_pos:]
    
    # 写入文件
    try:
        with open(file_path, 'w', encoding='utf-8', newline='') as f:
            f.write(new_content)
    except Exception as e:
        print(f"❌ 无法写入文件 {file_path}: {e}")
        # 恢复备份
        if not no_backup:
            shutil.copy2(backup_path, file_path)
            os.remove(backup_path)
        return False
    
    return True


def main():
    parser = argparse.ArgumentParser(description='Qt头文件自动补全脚本 - 用于Qt版本升级时自动添加缺失的头文件')
    parser.add_argument('directory', nargs='?', default='.', help='要处理的目录（默认为当前目录）')
    parser.add_argument('--dry-run', action='store_true', help='预览模式，只显示要修改的文件，不实际修改')
    parser.add_argument('--no-backup', action='store_true', help='不创建备份文件（不推荐）')
    
    # 新增：文件类型控制参数
    parser.add_argument('--include-cpp', action='store_true', help='同时处理.cpp源文件（默认不处理）')
    parser.add_argument('--include-hpp', action='store_true', help='同时处理.hpp头文件（默认不处理）')
    parser.add_argument('--extensions', type=str, help='自定义要处理的文件扩展名，逗号分隔（例如：h,hpp,cpp），会覆盖其他文件类型参数')
    
    args = parser.parse_args()
    
    if not os.path.isdir(args.directory):
        print(f"❌ 错误：{args.directory} 不是一个有效的目录")
        return
    
    # 确定要处理的文件扩展名
    if args.extensions:
        extensions = [ext.strip() for ext in args.extensions.split(',') if ext.strip()]
        # 自动添加点前缀（如果用户没有提供）
        extensions = [ext if ext.startswith('.') else '.' + ext for ext in extensions]
    else:
        extensions = ['.h']
        if args.include_hpp:
            extensions.append('.hpp')
        if args.include_cpp:
            extensions.append('.cpp')
    
    print(f"🔍 开始在目录 {args.directory} 中搜索文件...")
    print(f"📋 要检测的Qt类: {', '.join(QT_CLASS_INCLUDES.keys())}")
    print(f"📁 要处理的文件类型: {', '.join(extensions)}")
    if args.dry_run:
        print("⚠️  预览模式：不会修改任何文件")
    print("-" * 80)
    
    modified_count = 0
    total_files = 0
    
    # 递归遍历所有文件
    for root, dirs, files in os.walk(args.directory):
        # 跳过常见的不需要处理的目录
        dirs[:] = [d for d in dirs if d not in ['.git', 'build', 'bin', 'lib', 'thirdparty', '3rdparty', 'cmake-build-*']]
        
        for file in files:
            # 检查文件扩展名
            if any(file.endswith(ext) for ext in extensions):
                total_files += 1
                file_path = os.path.join(root, file)
                if process_file(file_path, args.dry_run, args.no_backup):
                    modified_count += 1
    
    print("-" * 80)
    print(f"✅ 处理完成！")
    print(f"📊 总计扫描了 {total_files} 个文件")
    print(f"🔧 需要修改的文件数: {modified_count}")
    if not args.dry_run and modified_count > 0 and not args.no_backup:
        print(f"💾 所有修改的文件都已备份为 .bak 文件")
        print(f"⚠️  请仔细检查修改后的代码，确保没有问题")


if __name__ == "__main__":
    main()