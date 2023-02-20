local utils = require "nvim-ev3.utils"
local pt = require "nvim-ev3.project_tools"

local M = {}

local _config = {}

local project_name
local user = ""
local host = ""
local interpreter = ""
local project_loaded = false

function M.setup(config)
    _config = config
end

function M.create_ev3_project()
    -- Create a new project for EV3
    -- Change pwd for nvim to projects directory
    vim.cmd("cd " .. _config.projects_dir)
    -- Ask user for project name
    project_name = pt.ask_project_name()
    if project_name then
        -- Ask user for username
        user = pt.ask_username()
        -- Ask user for hostname (or ip-address)
        host = pt.ask_hostname()
        -- Ask user for interpreter (python or micro-python)
        interpreter = pt.ask_interpreter()
        -- Check if it's a new or an existing project
        if utils.is_project(project_name) then
            -- Existing project
            new_project = false
            -- Ask user to overwrite project or not
            vim.ui.input({
                prompt = "Project already exists! Overwrite? [y,N]: "
            }, function(input)
                if input == "y" then
                    overwrite = true
                    -- Delete all existing project files
                    local os = utils.get_os()
                    if os == "Windows" then
                        vim.cmd("!del /s /q " .. project_name)
                    else
                        vim.cmd("!rm -rf " .. project_name .. "/*")
                    end
                else
                    overwrite = false
                end
            end)
        else
            -- Directory does not exist, so it's a new project
            new_project = true
            -- Create project directory
            -- os.execute("mkdir " .. project_name)
            local results = io.popen("mkdir " .. project_name)
            results:close()
        end
        -- Write project data for new project or overwrite existing project
        if new_project or overwrite then
            -- Write project file (.project.ini)
            project_file = project_name .. "/.project.ini"
            pt.write_project_file(project_file, project_name,
                                  user, host, interpreter)
            -- Write empty main file (main.py)
            pt.write_main_file(interpreter, _config.projects_dir, project_name)
            -- Open main file of the new project
            vim.cmd("e " .. project_name .. "/main.py")
        end
        -- Done, project is loaded
        project_loaded = true
    else
        -- User didn't enter a project name, so project cannot be created
        print("You cancelled the creation of a new project")
    end
end

function M.open_ev3_project()
    -- Open an existing EV3 project
    -- Set pwd to projects directory
    vim.cmd("cd " .. _config.projects_dir)
    -- Check operating system
    os = utils.get_os()
    -- Get all project directories in projects directory
    dir_list = utils.list_projects()
    -- Let user select desired project
    vim.ui.select( dir_list, {
        prompt = "Select a project",
        format_item = function(item)
            return item
        end,
    }, function(dir, idx)
        if dir then
            project_name = dir
            project_file = project_name .. "/.project.ini"
            user, host, interpreter = pt.read_project_file(project_file)
            print("  -  Project " .. project_name .. " successfully opened")
            project_loaded = true
            -- Open main file of chosen project
            -- vim.cmd("e " .. project_name .. "/main.py")
            vim.cmd("Ex " .. project_name .. "/")
            vim.cmd("call feedkeys('<CR>')")
        else
            print "You cancelled"
        end
    end)
end

function M.upload_ev3_project()
    -- Upload project to EV3
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
        -- Check operating system
        local os = utils.get_os()
        if os == "Windows" then
            cmd = "scp -r " .. project_name .. "/ " ..
                  user .. "@" .. host .. ":/home/" .. user
        else
            cmd = "rsync -auv --exclude=.project.ini " .. 
                  project_name .. "/ " .. user .. "@" .. host .. 
                  ":/home/" .. user .. "/"  .. project_name
        end
        local handle = io.popen(cmd)
        local result = handle:read("*a")
        handle.close()
        print("Upload done")
    end
end

function M.run_ev3_project()
    -- Run project on EV3 device
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
        if (interpreter == "python") then
            cmd = "ssh " .. user .. "@" .. host  .. " python3 /home/" ..
                  user .. "/" .. project_name .. "/main.py"
        else
            cmd = "ssh " .. user .. "@" .. host  ..
                  " brickrun -r -- pybricks-micropython /home/" ..
                  user .. "/" .. project_name .. "/main.py"
        end
        local handle = io.popen(cmd)
        local result = handle:read("a")
        handle.close()
        print("Program finished")
    end
end

function M.check_battery()
    -- Check the current voltage of EV3 check_battery
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
        local os = utils.get_os()
        if os == "Windows" then
            cmd = "ssh " .. user .. "@" .. host ..
                  " cat /sys/class/power_supply/lego-ev3-battery/voltage_now"
        else
            cmd = "ssh " .. user .. "@" .. host ..
                  " 'cat /sys/class/power_supply/lego-ev3-battery/voltage_now'"
        end
        local handle = io.popen(cmd)
        local result = handle:read("a")
        result = tonumber(result) / 10e5
        print("Current battery voltage: " .. result .. " v")
        handle.close()
    end
end

function M.open_terminal_ev3()
    -- Open an SSH-terminal on the EV3, directly in project directory
    -- Requires toggleterm plugin ('akinsho/toggleterm.nvim')
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
        local os = utils.get_os()
        local Terminal = require("toggleterm.terminal").Terminal
        if os == "Windows" then
            cmd = "ssh -t " .. user .. "@" .. host ..
                        " cd " .. project_name .. " ; bash"
        else
            cmd = "ssh -t " .. user .. "@" .. host ..
                        " 'cd " .. project_name .. " ; bash'"
        end
        local terminal_ev3 = Terminal:new({ cmd = cmd, hidden = true })
        terminal_ev3:toggle()
    end
end

return M

