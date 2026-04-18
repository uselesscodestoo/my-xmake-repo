package("picolibc")
    set_description("C Standard Library implementation for embedded systems")
    set_urls("https://github.com/picolibc/picolibc/releases/download/$(version)/picolibc-$(version).tar.xz",
             "https://github.com/picolibc/picolibc.git")
    
    add_versions("1.8.11", "f7edb0869e64b9d687f46961adeef7154921fe92")

    add_deps("meson", "ninja")

    on_install(function (package)
        local configs = {
            "-Dbuildtype=release",
            "-Ddefault_library=static",
         }
        table.insert(configs, "-Dsingle-thread=true")
        table.insert(configs, "-Dthread-local-storage=false")
        
        import("package.tools.meson").install(package, configs, {ldflags = { "-nostdlib", "-fuse-ld=lld"} })
    end)