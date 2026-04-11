package("ela-widget-tools")
    set_urls("https://github.com/Liniyous/ElaWidgetTools.git",
            "https://gh-proxy.com/https://github.com/Liniyous/ElaWidgetTools.git")
    set_description("ElaWidgetTools is a set of tools for ElaWidget")
    set_license("MIT")
    
    add_versions("2026.4.9", "2488f5d4a6bc65154d17aaaa3dc4714ba0ec3aa3")

    add_patches("2026.4.9", "patches/2026.4.9/fix-windows-moc.patch", "b531b581497076f67e3fa06b17d89e84f5e9faa9f9d89279b031307b688f9838")

    on_install(function (package)
        local sourcedir = package:cachedir()
        local scriptdir = path.join(os.scriptdir(), "scripts")
        local python_exe = nil

        if os.execv("python3", {"--version"}, {try=true}) == 0 then
            python_exe = "python3"
        elseif os.execv("python", {"--version"}, {try=true}) == 0 then
            python_exe = "python"
        else
            raise("Python 解释器未找到！请安装 Python 3.6+")
        end
        os.runv(python_exe, {
            path.join(scriptdir, "qt_fix_includes.py"),
            sourcedir, "--no-backup"
        })
        os.runv(python_exe, {
            path.join(scriptdir, "qchar_enum_fix.py"),
            sourcedir, "--no-backup"
        })

        io.writefile("xmake.lua",[[
            add_rules("mode.debug", "mode.release")
            if is_plat("windows") then
                add_cxflags("/utf-8")
            end
            target("ela-widget-tools")
                set_kind("$(kind)")
                add_rules("qt.$(kind)")
                set_languages("c++17")
                add_frameworks("QtCore", "QtWidgets", "QtGui")
                
                add_files("ElaWidgetTools/*.cpp")
                add_files("ElaWidgetTools/*.h")
                add_files("ElaWidgetTools/private/*.cpp")
                add_files("ElaWidgetTools/private/*.h")
                add_files("ElaWidgetTools/DeveloperComponents/*.cpp")
                add_files("ElaWidgetTools/DeveloperComponents/*.h")
                add_files("ElaWidgetTools/DeveloperComponents/*.cpp")
                add_files("ElaWidgetTools/DeveloperComponents/Command/*.h")
                add_files("ElaWidgetTools/DeveloperComponents/Command/*.cpp")
                add_includedirs("ElaWidgetTools", {public = true})
                add_includedirs("ElaWidgetTools/DeveloperComponents", {public = false})
                add_includedirs("ElaWidgetTools/DeveloperComponents/Command", {public = false})
                add_includedirs("ElaWidgetTools/private", {public = false})
                add_files("ElaWidgetTools/ElaWidgetTools.qrc")
                add_headerfiles("ElaWidgetTools/*.h")
                add_defines("ELAWIDGETTOOLS_LIBRARY")
        ]])
        
        import("package.tools.xmake").install(package)
    end)