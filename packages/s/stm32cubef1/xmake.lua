package("stm32cubef1")
    set_urls("https://github.com/STMicroelectronics/STM32CubeF1.git")
    set_description("STM32CubeF1 Package")
    add_versions("1.8.7", "d12e75247d5bcedc734f829b394517ab4c2726e3")

    local devices = {
        "stm32f100",
        "stm32f101",
        "stm32f102",
        "stm32f103",
        "stm32f105",
        "stm32f107",
    }
    add_configs("device", {description = "Set Target Device", default = "stm32f103", values = devices})

    local memory_types = { "x6", "xb", "xc", "xe", "xg" }
    add_configs("memory", {description = "Set Target Memory Type", default = "xb", values = memory_types})

    on_load(function(package)
        local full_device_name = package:config("device") .. package:config("memory")
        package:set("full_device_name", full_device_name)
        local capital_device_name = string.upper(full_device_name)
        local available_devices = {
            "stm32f100xb",
            "stm32f100xe",
            "stm32f101x6",
            "stm32f101xb",
            "stm32f101xe",
            "stm32f101xg",
            "stm32f102x6",
            "stm32f102xb",
            "stm32f103x6",
            "stm32f103xb",
            "stm32f103xe",
            "stm32f103xg",
            "stm32f105xc",
            "stm32f107xc",
        }
        local function contains(list, item)
            for _, v in ipairs(list) do
                if v == item then
                    return true
                end
            end
            return false
        end
        if not contains(available_devices, full_device_name) then
            raise("Device not available")
        end

        local define = string.upper(package:config("device")) .. package:config("memory"):sub(1, 1) .. package:config("memory"):sub(2, 2):upper()
        package:set("device_define", define)
        package:add("defines", define)

        local startup_file = "startup_" .. full_device_name .. ".s"
        package:set("startup_file", startup_file)
        package:set("ld_file", capital_device_name .. "_FLASH.ld")
        
        local cmsis_dir = path.join(package:cachedir(), "source/stm32cubef1", "Drivers/CMSIS")
        local cmsis_decice_dir = path.join(cmsis_dir, "Device/ST/STM32F1xx")
        local template_dir = path.join(cmsis_decice_dir, "Source/Templates")
        package:set("linker_full_path", path.join(template_dir, "gcc", "linker", capital_device_name .. "_FLASH.ld"))
        package:add("ldflags", "-T " .. path.join(package:installdir("linker"), capital_device_name .. "_FLASH.ld"))
    end)

    on_install(function(package)
        os.cp(package:get("linker_full_path"), path.join(package:installdir("linker")))
        
        io.writefile("Drivers/CMSIS/Device/ST/STM32F1xx/xmake.lua", string.format([[
            add_rules("mode.debug", "mode.release")
            target("stm32f1-cmsis-driver")
                add_files("Source/Templates/system_stm32f1xx.c")
                add_files("Source/Templates/gcc/%s")
                add_files("Source/Templates/gcc/linker/%s")
                add_headerfiles("Include/system_stm32f1xx.h")
                add_headerfiles("Include/stm32f1xx.h")
                add_headerfiles("Include/%s.h")
                add_includedirs("Include", {public = true})
                add_defines("%s")
        ]], package:get("startup_file"), package:get("ld_file"), package:get("full_device_name"), package:get("device_define")))

        io.writefile("Drivers/CMSIS/xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            add_includedirs("Include", {public = true})
            includes("Device/ST/STM32F1xx")
            target("stm32f1-cmsis")
                add_deps("stm32f1-cmsis-driver")
                add_headerfiles("Include/core_cm3.h")
                add_headerfiles("Include/cmsis_compiler.h")
                add_headerfiles("Include/cmsis_gcc.h")
                add_headerfiles("Include/cmsis_version.h")
        ]])

        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_toolchains("clang")
            set_kind("static")
            includes("Drivers/CMSIS")
            target("stm32cubef1")
                add_deps("stm32f1-cmsis")
        ]])
        import("package.tools.xmake").install(package)

    end)

