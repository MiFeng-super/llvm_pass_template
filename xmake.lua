set_xmakever("2.8.2")

-- project
set_project("llvm_pass_template")

-- version
set_version("1.0", {build = "%Y%m%d%H%M"})

-- enable warnings 
set_warnings("all", "error")

-- set language: C99, c++ standard
set_languages("cxx17", "c99")

-- set rules
add_rules("mode.debug", "mode.release", "mode.releasedbg")
add_rules("plugin.compile_commands.autoupdate", {outputdir = ".vscode"})

-- packages
add_requires("llvm", {system = true})

-- variables
local passes = "hello_world"
local build_target_dir = "build/llvm_out"
local target_cpp = "Test/TestProgram.cpp"
local target_before_ll = build_target_dir .. "/target_before.ll"
local target_after_ll = build_target_dir .. "/target_after.ll"

-- target
target("llvm_pass_template")
    set_kind("shared")

    add_files("Transforms/main.cpp")
    add_files("Transforms/src/**.cpp")
    add_includedirs("Transforms/include")

    add_packages("llvm")

target("test")
    set_kind("phony")
    add_deps("llvm_pass_template")

    on_build(function(target)
        import("lib.detect.find_tool")

        local clang = find_tool("clang")
        os.mkdir(build_target_dir)

        print("Generating LLVM IR...")
        os.execv(clang.program, {"-S", "-emit-llvm", target_cpp, "-o", target_before_ll})
    end)

    on_run(function(target)
        import("lib.detect.find_tool")

        local opt = find_tool("opt")
        local pass_so = target:dep("llvm_pass_template"):targetfile()

        print("Running LLVM Pass...")
        os.execv(opt.program, {"-S", "-load-pass-plugin", pass_so, "-passes=" .. passes, target_before_ll, "-o", target_after_ll})
    end)

    on_clean(function(target)
        os.rm(build_target_dir)
    end)

    after_build(function(target)
        import("lib.detect.find_tool")
        import("core.project.project")
        import("core.base.json")

        local opt = find_tool("opt")
        local llvm_config = find_tool("llvm-config")
        local llvm_libdir = os.iorunv(llvm_config.program, {"--libdir"}):trim()
        local pass_so = target:dep("llvm_pass_template"):targetfile()
        local workspace = "${workspaceFolder}"

        local launch_conf = {
            version = "0.2.0",
            configurations = {
                {
                    type = "lldb",
                    request = "launch",
                    name = "Debug LLVM Pass",
                    program = opt.program,
                    args = {
                        "-S",
                        "-load-pass-plugin",
                        workspace .. "/" .. pass_so,
                        "-passes=" .. passes,
                        workspace .. "/" .. target_before_ll,
                        "-o",
                        workspace .. "/" .. target_after_ll
                    },
                    cwd = workspace,
                    preLaunchTask = "xmake: build",
                    env = {
                        LD_LIBRARY_PATH = llvm_libdir .. ":" .. path.directory(pass_so)
                    },
                    terminal = "integrated"
                }
            }
        }

        local vscode_dir = path.join(project.directory(), ".vscode")
        if not os.exists(vscode_dir) then os.mkdir(vscode_dir) end
        io.writefile(path.join(vscode_dir, "launch.json"), json.encode(launch_conf))
        print("launch.json updated!")
    end)
