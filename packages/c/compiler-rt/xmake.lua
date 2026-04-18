package("compiler-rt")
    set_description("LLVM Compiler RT")
    set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).src.tar.xz",
             "https://github.com/llvm/llvm-project.git")

    add_versions("22.1.3", "e9846648fd6183ee6d8cbdb4502213fcf902a211")

    add_deps("cmake")
    add_deps("picolibc")

    on_load(function (package)
        local arch = package:arch()
        local system_name = package:targetos()
        if not system_name then 
            system_name = "linux"
        end
        package:add("linkdirs", path.join("lib", system_name))
        package:add("links", "clang_rt.builtins-" .. arch)
    end)

    on_install(function (package)
        local arch = package:arch()
        local os = package:targetos()
        if (not os) or (os == "generic") then 
            os = "none-eabi"
        end
        local triple = arch .. "-" .. os

        local system_name = package:targetos()
        if not system_name then 
            system_name = "linux"
        end
        system_name = system_name:sub(1, 1):upper() .. system_name:sub(2)

        local configs = {
            "-S" .. path.join(package:cachedir(), "source/compiler-rt/", "compiler-rt"),
            "-B" .. path.join(package:cachedir(), "source/compiler-rt/", "bd"),
            "-DCMAKE_C_COMPILER_TARGET=" .. triple,
            "-DCMAKE_CXX_COMPILER_TARGET=" .. triple,
            "-DCMAKE_ASM_COMPILER_TARGET=" .. triple,
            "-DCMAKE_SYSTEM_NAME=" .. system_name,
            "-DCMAKE_CROSSCOMPILING=ON",
            "-DCMAKE_BUILD_TYPE=Release",
            "-DCOMPILER_RT_BUILD_BUILTINS=ON",
            "-DCOMPILER_RT_BUILD_SANITIZERS=OFF",
            "-DCOMPILER_RT_BUILD_XRAY=OFF",
            "-DCOMPILER_RT_BUILD_LIBFUZZER=OFF",
            "-DCOMPILER_RT_BUILD_PROFILE=OFF",
            "-DCOMPILER_RT_BUILD_CTX_PROFILE=OFF",
            "-DCOMPILER_RT_BUILD_MEMPROF=OFF",
            "-DCOMPILER_RT_BUILD_ORC=OFF",
            "-DCOMPILER_RT_BUILD_GWP_ASAN=OFF",
            "-DCOMPILER_RT_SCUDO_STANDALONE_BUILD_SHARED=OFF",
            "-DCOMPILER_RT_BAREMETAL_BUILD=ON",
            "-DCOMPILER_RT_DEFAULT_TARGET_ONLY=ON",
        }

        table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:targetarch())
        import("package.tools.cmake").install(package, configs, {builddir = "bd", ldflags = { "-fuse-ld=lld", "-nostdlib" }})
    end)