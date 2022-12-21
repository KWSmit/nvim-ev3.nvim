local utils = require "nvim-ev3.utils"
local pt = require "nvim-ev3.project_tools"

local M = {}

local base_projects_dir = "/home/kees/Sources/nvim-plugins/test/"
local project_name
local user = ""
local host = ""
local interpreter = ""
local project_loaded = false


function M.create_ev3_project()
    -- Create a new project for EV3
    -- Change pwd for nvim to base_projects_dir
    vim.cmd('cd ' .. base_projects_dir)
    -- Ask user for project name
    vim.ui.input({
        prompt = "Enter project name: ",
    }, function(input)
        if input then
            project_name = input
        else
            print("You cancelled")
        end
    end)
    -- Ask user for username
    vim.ui.input({
        prompt = "Enter username: ",
        default = "robot",
    }, function(input)
        if input then
            username = input
        else
            print("You cancelled")
        end
    end)
    -- Ask user for hostname (or ip-address)
    vim.ui.input({
        prompt = "Enter host: ",
    }, function(input)
        if input then
            host = input
        else
            print("You cancelled")
        end
    end)
    -- Ask user for interpreter (python or micro-python)
    vim.ui.input({
        prompt = "Choose interpreter: 1=python, 2=micro-python: ",
        default = 2
    }, function(input)
        if input == "1" then
            interpreter = "python"
        elseif input == "2" then
            interpreter = "micro-python"
        else
            interpreter = "micro-python"
        end
    end)
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
            else
                overwrite = false
            end
        end)
    else
        -- Directory does not exist, so it's a new project
        new_project = true
    end
    -- If it's a new project: create project directory
    if new_project then
        os.execute('mkdir ' .. project_name)
        print('mkdir ' .. project_name)
    end
    -- Write project data for new project or overwrite existing project
    -- TODO clear all files in case of existing project
    if new_project or overwrite then
        -- Write project file (.project.ini)
        project_file = base_projects_dir .. project_name .. '/.project.ini'
        pt.write_project_file(project_file, project_name,
                              username, host, interpreter)
        -- Write empty main file (main.py)
        if (interpreter == 'python') then
            pt.write_main_python(base_projects_dir, project_name)
        else
            pt.write_main_micro_python(base_projects_dir, project_name)
        end
    end
    -- Done, project is loaded
    project_loaded = true
end

function M.open_ev3_project()
    -- Open an existing EV3 project
    -- TODO: let user select from list of project instead of typing manually
    -- See: https://alpha2phi.medium.com/neovim-for-beginners-user-interface-568879ecfd6d
    -- Set pwd to base_projects_dir
    vim.cmd('cd' .. base_projects_dir)
    -- Ask user for project_name
    vim.ui.input({
        prompt = "Enter project name: ",
    }, function(input)
        if input then
            -- Read data from project_file
            project_name = input
            project_file = base_projects_dir .. project_name .. "/.project.ini"
            user, host, interpreter = pt.read_project_file(project_file)
            print("  -  Project " .. project_name .. " successfully opened")
            project_loaded = true
        else
            print("You cancelled")
        end
    end)
end

function M.upload_ev3_project()
    -- Upload project to EV3
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
       local handle = io.popen('rsync -auv --exclude=.project.ini ' .. 
                               project_name .. '/ ' .. user .. '@' .. host .. 
                               ':/home/' .. user .. '/'  .. project_name)
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
        if (interpreter == 'python') then
            os.execute('ssh ' .. user .. '@' .. host  .. ' python3 /home/' ..
                       user .. '/' .. project_name .. '/main.py')
        else
            os.execute('ssh ' .. user .. '@' .. host  ..
                       ' brickrun -r -- pybricks-micropython /home/' ..
                       user .. '/' .. project_name .. '/main.py')
        end
        print("Done")
    end
end

function M.check_battery()
    -- Check the current voltage of EV3 check_battery
    if (project_loaded == false) then
        print("First open an EV3-project!")
    else
       local handle = io.popen('scp -l 2000 robot@192.168.2.14:/sys/class/power_supply/lego-ev3-battery/voltage_now /dev/stdout')
       local result = handle:read(7)
       result = tonumber(result) / 10e5
       print("Current battery voltage: " .. result .. "volt")
       handle.close()
    end
end

return M

