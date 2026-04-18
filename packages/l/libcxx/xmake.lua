package("libcxx")
        set_description("LLVM C++ Standard Library")
    set_urls("https://github.com/llvm/llvm-project/releases/download/llvmorg-$(version)/llvm-project-$(version).src.tar.xz",
             "https://github.com/llvm/llvm-project.git")

    add_versions("22.1.3", "e9846648fd6183ee6d8cbdb4502213fcf902a211")

    add_configs("shared", {description = "Build libc++ as a shared library.", default = false, type = "boolean"})
    add_configs("static", {description = "Build libc++ as a static library.", default = true, type = "boolean"})
    
    add_configs("exceptions", {description = "Enable exceptions in the built library.", default = false, type = "boolean"})
    add_configs("rtti", {description = "Use runtime type information. Set exception to true first before using rtti.", default = false, type = "boolean"})
    add_configs("filesystem", {description = "Whether to include support for parts of the library that rely on a filesystem being " ..
                                             "available on the platform. This includes things like most parts of <filesystem> and " ..
                                             "others like <fstream>", default = false, type = "boolean"})
    add_configs("include_tests", {description = "Build the libc++ tests.", default = false, type = "boolean"})
    add_configs("hardening_mode", {description = "Specify the default hardening mode to use. This mode will be used inside the " ..
                                                 "compiled library and will be the default when compiling user code. Note that " ..
                                                 "users can override this setting in their own code. This does not affect the ABI.",
                                    default = "none", values = {"none", "fast", "extensive", "debug"}})
    add_configs("assertion_semantic", {description = "Specify the default assertion semantic to use. This semantic will be used "   ..
                                                    "inside the compiled library and will be the default when compiling user code. "..
                                                    "Note that users can override this setting in their own code. This does not "   ..
                                                    "affect the ABI. `hardening_dependent` is a special value that instructs the "  ..
                                                    "library to select the assertion semantic based on the hardening mode in effect.", 
                                                    default = "hardening_dependent", values = 
                                                    {"hardening_dependent", "ignore", "observe", "quick_enforce", "enforce"}})
    add_configs("random_device", {description = "Whether to include support for std::random_device in the library. Disabling " ..
                                                "this can be useful when building the library for platforms that don't have "  ..
                                                "a source of randomness, such as some embedded platforms. When this is not "   ..
                                                "supported, most of <random> will still be available, but std::random_device " ..
                                                "will not.", default = false, type = "boolean"})
    add_configs("localization", {description = "Whether to include support for localization in the library. Disabling "       ..
                                               "localization can be useful when porting to platforms that don't support "     ..
                                               "the C locale API (e.g. embedded). When localization is not supported, "       ..
                                               "several parts of the library will be disabled: <iostream>, <regex>, <locale> "..
                                               "will be completely unusable, and other parts may be only partly available.", 
                                               default = false, type = "boolean"})
    add_configs("unicode", {description = "Whether to include support for Unicode in the library. Disabling Unicode can "..
                                          "be useful when porting to platforms that don't support UTF-8 encoding (e.g. " ..
                                          "embedded).", default = false, type = "boolean"})
    add_configs("terminal_available", {description = "Build libc++ with support for checking whether a stream is a terminal.", 
                                       default = false, type = "boolean"})
    add_configs("wide_characters", {description = "Whether to include support for wide characters in the library. Disabling "  ..
                                                  "wide character support can be useful when porting to platforms that don't " ..
                                                  "support the C functionality for wide characters. When wide characters are " ..
                                                  "not supported, several parts of the library will be disabled, notably the " ..
                                                  "wide character specializations of std::basic_string.", 
                                                  default = false, type = "boolean"})
    add_configs("threads", {description = "Build libc++ with support for threads.", default = false, type = "boolean"})
    add_configs("monotonic_clock", {description = "Build libc++ with support for a monotonic clock. Set threads to true first before using this option.", 
                                    default = false, type = "boolean"})
    add_configs("time_zone_database", {description = "Whether to include support for time zones in the library. Disabling "  ..
                                                      "time zone support can be useful when porting to platforms that don't " ..
                                                      "ship the IANA time zone database. When time zones are not supported, " ..
                                                      "time zone support in <chrono> will be disabled.", 
                                                      default = false, type = "boolean"})
    add_configs("vendor_availability_annotations", {description = "Whether to turn on vendor availability annotations on declarations that depend "    ..
                                                                  "on definitions in a shared library. By default, we assume that we're not building " ..
                                                                  "libc++ for any specific vendor, and we disable those annotations. Vendors wishing " ..
                                                                  "to provide compile-time errors when using features unavailable on some version of " ..
                                                                  "the shared library they shipped should turn this on and see `include/__configuration/availability.h` " ..
                                                                  "for more details.", default = false, type = "boolean"})
    -- add_configs("test_config", {description = "The path to the Lit testing configuration to use when running the tests. " ..
    --                                           "If a relative path is provided, it is assumed to be relative to '<monorepo>/libcxx/test/configs'..", 
    --                                           type = "string"})
    -- add_configs("test_params", {description = "A list of parameters to run the Lit test suite with.", type = "string"})
    add_configs("include_benchmarks", {description = "Build the libc++ benchmarks and their dependencies", default = false, type = "boolean"})
    add_configs("include_docs", {description = "Build the libc++ documentation.", default = false, type = "boolean"})
    add_configs("libdir_suffix", {description = "Define suffix of library directory name (32/64)", default = "", type = "string"})

    add_configs("install_headers", {description = "Install the libc++ headers.", default = true, type = "boolean"})
    add_configs("install_library", {description = "Install the libc++ library.", default = true, type = "boolean"})
    add_configs("install_modules", {description = "Install the libc++ C++20 module source files (experimental).", default = true, type = "boolean"})
    add_configs("install_static_library", {description = "Install the libc++ static library.", default = true, type = "boolean"})
    add_configs("install_shared_library", {description = "Install the libc++ shared library.", default = false, type = "boolean"})

    add_configs("abi_unstable", {description = "Use the unstable ABI of libc++. This is equivalent to specifying LIBCXX_ABI_VERSION=n, where n is the not-yet-stable version.", default = false, type = "boolean"})
    add_configs("abi_force_itanium", {description = "Ignore auto-detection and force use of the Itanium ABI.", default = false, type = "boolean"})
    add_configs("abi_force_microsoft", {description = "Ignore auto-detection and force use of the Microsoft ABI.", default = false, type = "boolean"})
    
    add_configs("typeinfo_comparison_implementation", 
                {description = "Override the implementation to use for comparing typeinfos. By default, this" ..
                "is detected automatically by the library, but this option allows overriding" ..
                "which implementation is used unconditionally.", default = "default", 
                values = {"default", "1", "2", "3"}})

    add_configs("abi_defines", {description = "A semicolon separated list of ABI macros to define in the site config header.", default = "", type = "string"})
    add_configs("extra_site_defines", {description = "Extra defines to add into __config_site", default = "", type = "string"})
    add_configs("use_compiler_rt", {description = "Use compiler-rt instead of libgcc", default = true, type = "boolean"})

    add_configs("cxx_abi", {description = "Specify C++ ABI library to use.", default = "none", 
                values = {"none", "libcxxabi", "system-libcxxabi", "libcxxrt", "libstdc++", "libsupc++", "vcruntime"}})

    add_configs("static_abi_library", {description = "Use a static copy of the ABI library when linking libc++.", default = true, type = "boolean"})
    add_configs("abi_link_script", {description = "Use and install a linker script for the given ABI library. Can not set both with static_abi_library.", default = false, type = "boolean"})

    add_configs("new_delete_definitions", {description = "Build libc++ with definitions for operator new/delete. These are normally" ..
                                                         "defined in libc++abi, but this option can be used to define them in libc++" ..
                                                         "instead. If you define them in libc++, make sure they are NOT defined in" ..
                                                         "libc++abi. Doing otherwise is an ODR violation.", default = true, type = "boolean"})

    add_configs("llvm_unwinder", {description = "Build and use the LLVM unwinder.", default = false, type = "boolean"})
    -- add_configs("build_32_bits", {description = "Build 32 bit multilib libc++. This option is not supported anymore when building the runtimes. Please specify a full triple instead.", default = false, type = "boolean"})

    add_configs("has_musl_libc", {description = "Build libc++ with support for the Musl C library", default = false, type = "boolean"})
    add_configs("has_pthread_api", {description = "Ignore auto-detection and force use of pthread API", default = false, type = "boolean"})
    add_configs("has_win32_thread_api", {description = "Ignore auto-detection and force use of win32 thread API", default = false, type = "boolean"})
    add_configs("has_external_thread_api", {description = "Build libc++ with an externalized threading API.", default = false, type = "boolean"})
    
    add_configs("pedantic", {description = "Compile with pedantic enabled.", default = false, type = "boolean"})
    add_configs("werror", {description = "Fail and stop if a warning is triggered.", default = false, type = "boolean"})
    
    add_configs("hermetic_static_library", {description = "Do not export any symbols from the static library.", default = false, type = "boolean"})
    
    add_configs("shared_output_name", {description = "Output name for the shared libc++ runtime library.", default = "c++dummy", type = "string"})
    add_configs("static_output_name", {description = "Output name for the static libc++ runtime library.", default = "c++", type = "string"})

    add_configs("libc", {description = "Specify C library to use.", default = "picolibc", values = {"system", "llvm-libc", "picolibc", "newlib"}})
    
    add_deps("cmake")

    on_load(function (package)
        if package:config("static_abi_library") and package:config("abi_link_script") then
            raise("static_abi_library and abi_link_script can not be enable both.")
        end
        if package:config("libc") == "picolibc" then
            package:add("deps", "picolibc")
        end

        package:add("includedirs", "include")
        package:add("includedirs", path.join("include", "c++", "v1"))
        package:add("linkdirs", "lib")
        package:add("links", "c++")
    end)

    on_install(function (package)
        local triple = package:toolchains()[1]:cross()
        if not triple then
            local arch = package:arch()
            local os = package:targetos()
            if (not os) or (os == "generic") then 
                os = "none-eabi"
            end
            triple = arch .. "-" .. os
        end

        local system_name = package:targetos()
        if not system_name then 
            system_name = "linux"
        end
        system_name = system_name:sub(1, 1):upper() .. system_name:sub(2)

        local configs = {
            "-S" .. path.join(package:cachedir(), "source/libcxx/", "libcxx"),
            "-B" .. path.join(package:cachedir(), "source/libcxx/", "bd"),
            "-DCMAKE_C_COMPILER_TARGET=" .. triple,
            "-DCMAKE_CXX_COMPILER_TARGET=" .. triple,
            "-DCMAKE_ASM_COMPILER_TARGET=" .. triple,
            "-DCMAKE_SYSTEM_NAME=" .. system_name,
            "-DCMAKE_SYSTEM_PROCESSOR=" .. package:targetarch(),
            "-DCMAKE_CROSSCOMPILING=ON",
            "-DCMAKE_BUILD_TYPE=Release",
            "-DPython3_EXECUTABLE=python3",
            "-DRUNTIMES_USE_LIBC=picolibc",
        }

        table.insert(configs, "-DLIBCXX_ENABLE_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_STATIC=" .. (package:config("static") and "ON" or "OFF"))
        
        table.insert(configs, "-DLIBCXX_ENABLE_EXCEPTIONS=" .. (package:config("exceptions") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_RTTI=" .. (package:config("rtti") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_FILESYSTEM=" .. (package:config("filesystem") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_INCLUDE_TESTS=" .. (package:config("include_tests") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_HARDENING_MODE=" .. package:config("hardening_mode"))
        table.insert(configs, "-DLIBCXX_ASSERTION_SEMANTIC=" .. package:config("assertion_semantic"))
        table.insert(configs, "-DLIBCXX_ENABLE_RANDOM_DEVICE=" .. (package:config("random_device") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_LOCALIZATION=" .. (package:config("localization") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_UNICODE=" .. (package:config("unicode") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_HAS_TERMINAL_AVAILABLE=" .. (package:config("terminal_available") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_WIDE_CHARACTERS=" .. (package:config("wide_characters") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_THREADS=" .. (package:config("threads") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_MONOTONIC_CLOCK=" .. (package:config("monotonic_clock") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_TIME_ZONE_DATABASE=" .. (package:config("time_zone_database") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_VENDOR_AVAILABILITY_ANNOTATIONS=" .. (package:config("vendor_availability_annotations") and "ON" or "OFF"))
        
        table.insert(configs, "-DLIBCXX_INCLUDE_BENCHMARKS=" .. (package:config("include_benchmarks") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_INCLUDE_DOCS=" .. (package:config("include_docs") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_LIBDIR_SUFFIX:STRING=" .. package:config("libdir_suffix"))
        table.insert(configs, "-DLIBCXX_INSTALL_HEADERS=" .. (package:config("install_headers") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_INSTALL_LIBRARY=" .. (package:config("install_library") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_INSTALL_MODULES=" .. (package:config("install_modules") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_INSTALL_STATIC_LIBRARY=" .. (package:config("install_static_library") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_INSTALL_SHARED_LIBRARY=" .. (package:config("install_shared_library") and "ON" or "OFF"))

        table.insert(configs, "-DDLIBCXX_ABI_UNSTABLE=" .. (package:config("abi_unstable") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ABI_FORCE_ITANIUM=" .. (package:config("abi_force_itanium") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ABI_FORCE_MICROSOFT=" .. (package:config("abi_force_microsoft") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_TYPEINFO_COMPARISON_IMPLEMENTATION:STRING=" .. package:config("typeinfo_comparison_implementation"))

        table.insert(configs, "-DLIBCXX_ABI_DEFINES:STRING=" .. package:config("abi_defines"))
        table.insert(configs, "-DLIBCXX_EXTRA_SITE_DEFINES:STRING=" .. package:config("extra_site_defines"))
        table.insert(configs, "-DLIBCXX_USE_COMPILER_RT=" .. (package:config("use_compiler_rt") and "ON" or "OFF"))

        table.insert(configs, "-DLIBCXX_CXX_ABI:STRING=" .. package:config("cxx_abi"))

        table.insert(configs, "-DLIBCXX_ENABLE_STATIC_ABI_LIBRARY=" .. (package:config("static_abi_library") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_ABI_LINKER_SCRIPT=" .. (package:config("abi_link_script") and "ON" or "OFF"))

        table.insert(configs, "-DLIBCXX_ENABLE_NEW_DELETE_DEFINITIONS=" .. (package:config("new_delete_definitions") and "ON" or "OFF"))

        table.insert(configs, "-DLIBCXXABI_USE_LLVM_UNWINDER=" .. (package:config("llvm_unwinder") and "ON" or "OFF"))

        table.insert(configs, "-DLIBCXX_HAS_MUSL_LIBC=" .. (package:config("has_musl_libc") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_HAS_PTHREAD_API=" .. (package:config("has_pthread_api") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_HAS_WIN32_THREAD_API=" .. (package:config("has_win32_thread_api") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_HAS_EXTERNAL_THREAD_API=" .. (package:config("has_external_thread_api") and "ON" or "OFF"))

        table.insert(configs, "-DLIBCXX_ENABLE_PEDANTIC=" .. (package:config("pedantic") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCXX_ENABLE_WERROR=" .. (package:config("werror") and "ON" or "OFF"))

        table.insert(configs, "-DLIBCXX_HERMETIC_STATIC_LIBRARY=" .. (package:config("hermetic_static_library") and "ON" or "OFF"))

        table.insert(configs, "-DLIBCXX_SHARED_OUTPUT_NAME:STRING=" .. package:config("shared_output_name"))
        table.insert(configs, "-DLIBCXX_STATIC_OUTPUT_NAME:STRING=" .. package:config("static_output_name"))
        
        table.insert(configs, "-DRUNTIMES_USE_LIBC:STRING=" .. package:config("libc"))

        local cxflags = { "-nostdlib", "-fno-common" }
        local sysincludedirs = {}
        local syslinkdirs = {}
        local syslinks = {}
        if package:config("libc") == "picolibc" then
            local picolibc = package:dep("picolibc")
            local additional_cx_flags = "-I" .. picolibc:installdir("include")
            -- table.insert(configs, "-DLIBCXX_ADDITIONAL_COMPILE_FLAGS:STRING=\"" .. additional_cx_flags .. "\"")
            table.insert(cxflags, additional_cx_flags)
            table.insert(sysincludedirs, picolibc:installdir("include"))
            table.insert(syslinkdirs, picolibc:installdir("lib"))
            for _, link in ipairs(picolibc:get("links")) do
                table.insert(syslinks, link)
            end
            print(picolibc:get("links"))
        end

        import("package.tools.cmake").install(package, configs, {builddir = "bd", 
                                                                cxflags = cxflags, 
                                                                ldflags = { "-fuse-ld=lld", "-nostdlib" },
                                                                includedirs = sysincludedirs,
                                                                linkdirs = syslinkdirs,
                                                                links = syslinks,
                                                                })
    end)