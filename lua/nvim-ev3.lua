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
        if utils.isdir(project_name) then
            -- Existing project
            new_project = false
            -- Ask user to overwrite project or not
            vim.ui.input({
                prompt = "Project already exists! Overwrite? [y,N]: "
            }, function(input)
                if input == "y" then
                    overwrite = true
                    -- Delete all existing project files
                    vim.cmd("!rm -rf " .. project_name .. "/*")
                else
                    overwrite = false
                end
            end)
        else
            -- Directory does not exist, so it's a new project
            new_project = true
            -- Create project directory
            os.execute("mkdir " .. project_name)
        end
        -- Write project data for new project or overwrite existing project
        if new_project or overwrite then
            -- Write project file (.project.ini)
            project_file = _config.projects_dir .. project_name .. "/.project.ini"
            pt.write_project_file(project_file, project_name,
                                  user, host, interpreter)
            -- Write empty main file (main.py)
            pt.write_main_file(interpreter, _config.projects_dir, project_name)
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
    -- Get all project directories in projects directory
    dir_list = {}
    for dir in io.popen("ls -d " .. _config.projects_dir .. "*"):lines() do
        table.insert(dir_list, vim.fn.fnamemodify(dir, ":t"))
    end
    -- Let user select desired project
    vim.ui.select( dir_list, {
        prompt = "Select a project",
        format_item = function(item)
            return item
        end,
    }, function(dir, idx)
        if dir then
            project_name = dir
            project_file = _config.projects_dir .. project_name .. "/.project.ini"
            user, host, interpreter = pt.read_project_file(project_file)
            print("  -  Project " .. project_name .. " successfully opened")
            project_loaded = true
        else
            print "You cancelled"
        end
    end)
    -- Open main file of chosen project
   vim.cmd("e " .. project_name .. "/main.py")
   vim.cmd("call feedkeys('<CR>')")
end

function M.upload_ev3_project()
    -- Upload project to EV3
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
       local handle = io.popen("rsync -auv --exclude=.project.ini " .. 
                               project_name .. "/ " .. user .. "@" .. host .. 
                               ":/home/" .. user .. "/"  .. project_name)
       local result = handle:read("*a")
       print("result: " .. result)
       handle.close()
    end
end

function M.run_ev3_project()
    -- Run project on EV3 device
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
        if (interpreter == "python") then
            os.execute("ssh " .. user .. "@" .. host  .. " python3 /home/" ..
                       user .. "/" .. project_name .. "/main.py")
        else
            os.execute("ssh " .. user .. "@" .. host  ..
                       " brickrun -r -- pybricks-micropython /home/" ..
                       user .. "/" .. project_name .. "/main.py")
        end
        print("Done")
    end
end

function M.check_battery()
    -- Check the current voltage of EV3 check_battery
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
        local bat_file = ":/sys/class/power_supply/lego-ev3-battery/voltage_now"
        local handle = io.popen("scp -l 2000 " .. user .. "@" .. host ..
                                bat_file .. " /dev/stdout 2> /dev/null")
        local result = handle:read()
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
        local Terminal = require("toggleterm.terminal").Terminal
        local cmd = "ssh -t " .. user .. "@" .. host .. " 'cd " .. "/home/" .. 
                    user .. "/" .. project_name .. " ; bash'"
        local terminal_ev3 = Terminal:new({ cmd = cmd, hidden = true })
        terminal_ev3:toggle()
    end
end

return M

