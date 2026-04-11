# -*- coding: utf-8 -*-
"""
QT QChar Enum构造函数迁移辅助脚本
专门用于修复: QChar(enum) -> QChar((int)enum)
"""

import os
import re
import argparse
import shutil
from datetime import datetime
import sys
try: 
    sys.stdout.reconfigure(encoding='utf-8')
except:
    pass

class QCharEnumMigrationHelper:
    def __init__(self, root_dir, backup=True, interactive=False):
        self.root_dir = os.path.abspath(root_dir)
        self.backup = backup
        self.interactive = interactive
        self.modified_files = 0
        self.total_changes = 0
        self.skipped_changes = 0
        
        # 简化的正则表达式策略：
        # 1. 先找到所有 QChar(...) 的位置
        # 2. 然后提取括号内的内容进行分析
        self.qchar_pattern = re.compile(r'QChar\s*\(')
    
    def find_source_files(self):
        """查找所有需要处理的源文件"""
        source_files = []
        for root, dirs, files in os.walk(self.root_dir):
            for file in files:
                if file.endswith(('.cpp', '.h', '.hpp', '.cxx', '.hxx')):
                    source_files.append(os.path.join(root, file))
        return source_files
    
    def extract_balanced_content(self, line, start_pos):
        """从起始位置提取匹配的括号内容"""
        count = 1
        i = start_pos
        while i < len(line) and count > 0:
            if line[i] == '(':
                count += 1
            elif line[i] == ')':
                count -= 1
            i += 1
        return i - 1
    
    def needs_conversion(self, content):
        """判断内容是否需要转换（排除已经有(int)的情况）"""
        # 检查是否已经有 (int) 转换
        if content.strip().startswith('(int)'):
            return False
        
        # 检查是否是字面量（数字、字符、字符串等）
        content_stripped = content.strip()
        if (content_stripped.isdigit() or 
            (content_stripped.startswith(('"', "'")) and content_stripped.endswith(('"', "'"))) or
            content_stripped in ('true', 'false', 'nullptr', 'NULL')):
            return False
        
        # 其他情况都认为需要转换
        return True
    
    def process_line(self, line, file_path, line_num):
        """处理单行代码"""
        original_line = line
        changes_made = 0
        result = []
        last_pos = 0
        
        # 查找所有 QChar( 的位置
        for match in self.qchar_pattern.finditer(line):
            start_pos = match.end()
            # 找到匹配的右括号
            end_pos = self.extract_balanced_content(line, start_pos)
            
            if end_pos > start_pos:
                content = line[start_pos:end_pos]
                
                if self.needs_conversion(content):
                    # 添加到结果
                    result.append(line[last_pos:match.start()])
                    result.append('QChar((')
                    result.append('int)')
                    result.append(content)
                    result.append(')')
                    
                    last_pos = end_pos + 1
                    changes_made += 1
        
        # 添加剩余部分
        result.append(line[last_pos:])
        line = ''.join(result)
        
        if changes_made > 0 and self.interactive:
            print(f"\n{'='*60}")
            print(f"文件: {file_path}")
            print(f"行号: {line_num}")
            print(f"原始: {original_line.rstrip()}")
            print(f"修改: {line.rstrip()}")
            
            while True:
                choice = input("\n确认修改? [Y=是/n=否/s=跳过这个文件/q=全部退出]: ").strip().lower()
                if choice in ('', 'y', 'yes'):
                    self.total_changes += changes_made
                    return line, True, False
                elif choice in ('n', 'no'):
                    self.skipped_changes += changes_made
                    return original_line, False, False
                elif choice in ('s', 'skip', 'skip_file'):
                    self.skipped_changes += changes_made
                    return original_line, False, True
                elif choice in ('q', 'quit', 'exit'):
                    print("用户退出")
                    raise SystemExit(0)
                else:
                    print("无效输入，请重新选择")
        
        if changes_made > 0:
            self.total_changes += changes_made
            return line, True, False
        
        return line, False, False
    
    def backup_file(self, file_path):
        """备份文件"""
        if not self.backup:
            return
        backup_dir = os.path.join(os.path.dirname(file_path), "qt_migration_backup")
        os.makedirs(backup_dir, exist_ok=True)
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"{os.path.basename(file_path)}.{timestamp}.bak"
        backup_path = os.path.join(backup_dir, backup_name)
        
        shutil.copy2(file_path, backup_path)
        return backup_path
    
    def process_file(self, file_path):
        """处理单个文件"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        except UnicodeDecodeError:
            try:
                with open(file_path, 'r', encoding='gbk') as f:
                    lines = f.readlines()
            except:
                print(f"警告: 无法读取文件 {file_path}，跳过")
                return False
        
        modified = False
        new_lines = []
        skip_file = False
        
        for line_num, line in enumerate(lines, 1):
            if skip_file:
                new_lines.append(line)
                continue
                
            new_line, line_modified, skip_file = self.process_line(line, file_path, line_num)
            new_lines.append(new_line)
            if line_modified:
                modified = True
        
        if modified:
            self.backup_file(file_path)
            with open(file_path, 'w', encoding='utf-8', newline='') as f:
                f.writelines(new_lines)
            self.modified_files += 1
            print(f"✓ 已修改: {file_path}")
        
        return modified
    
    def run(self):
        """运行迁移辅助工具"""
        print(f"{'='*60}")
        print(f"QT QChar Enum构造函数迁移辅助工具")
        print(f"{'='*60}")
        print(f"扫描目录: {self.root_dir}")
        print(f"处理模式: {'交互式确认' if self.interactive else '自动批量修改'}")
        print(f"备份文件: {'开启' if self.backup else '关闭'}")
        print(f"修复目标: QChar(enum) -> QChar((int)enum)")
        print(f"{'='*60}")
        
        source_files = self.find_source_files()
        print(f"\n找到 {len(source_files)} 个源文件\n")
        
        for i, file_path in enumerate(source_files, 1):
            print(f"[{i}/{len(source_files)}] 处理: {file_path}")
            self.process_file(file_path)
        
        print(f"\n{'='*60}")
        print("处理完成!")
        print(f"{'='*60}")
        print(f"修改文件数: {self.modified_files}")
        print(f"总修改次数: {self.total_changes}")
        print(f"跳过修改数: {self.skipped_changes}")
        
        if self.backup and self.modified_files > 0:
            print(f"\n注意: 原始文件已备份到各目录下的 qt_migration_backup 文件夹中")
            print(f"      备份文件命名格式: 原文件名.时间戳.bak")

def main():
    parser = argparse.ArgumentParser(
        description='QT QChar Enum构造函数迁移辅助工具\n'
                    '专门修复: QChar(enum) -> QChar((int)enum)',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    parser.add_argument('directory', help='要扫描的根目录')
    parser.add_argument('-i', '--interactive', action='store_true', 
                        help='交互式模式，逐个确认修改')
    parser.add_argument('--no-backup', action='store_true',
                        help='不备份原始文件（不推荐）')
    
    args = parser.parse_args()
    
    helper = QCharEnumMigrationHelper(
        root_dir=args.directory,
        backup=not args.no_backup,
        interactive=args.interactive
    )
    
    helper.run()

if __name__ == "__main__":
    main()