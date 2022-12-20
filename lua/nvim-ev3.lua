local utils = require "nvim-ev3.utils"

local M = {}

local base_projects_dir = "/home/kees/Sources/nvim-plugins/test/"
local project_name
local user = ""
local host = ""
local interpreter = ""
local project_loaded = false

local function write_project_file(user, host, project_name, interpreter)
    -- Write data to project file
    project_file = base_projects_dir .. project_name .. "/.project.ini"
    f = io.open(project_file, "w")
    io.output(f)
    io.write("USER=" .. user .. "\n")
    io.write("HOST=" .. host .. "\n")
    io.write("DIR=home/" .. user .. "/" .. project_name .. "\n")
    io.write("SCRIPT=main.py" .. "\n")
    io.write("INTERPRETER=" .. interpreter)
    io.close(f)
end

local function read_project_file(project_file)
    --- Read data from project_file
    f = io.open(project_file, "r")
    -- Read user
    line = f:read("*l")
    line = utils.split_string(line, "=")
    user = line[2]
    -- Read host
    line = f:read("*l")
    line = utils.split_string(line, "=")
    host = line[2]
    -- Read interpreter, first read lines with dir and SCRIPT
    line = f:read("*l")
    line = f:read("*l")
    line = f:read("*l")
    line = utils.split_string(line, "=")
    interpreter = line[2]
    io.close(f)
    return user, host, interpreter
end

local function write_main_python()
    -- Write main.py for python interpreter
    python_code = 
    "#!/user/bin/env python3 \n" ..
    "# \n" ..
    "# Name:        main.py \n" ..
    "# Description:  \n" ..
    "# Author:       \n" ..
    "# Version:      \n" ..
    "# Date:         \n" ..
    "# \n"
    main_file = base_projects_dir .. project_name .. '/main.py'
    f = io.open(main_file, 'w')
    f:write(python_code)
    io.close(f)
end

local function write_main_micro_python()
    -- Write main.py for micro-python interpreter
    micro_python_code = 
    "#!/usr/bin/env pybricks-micropython \n" ..
    "# \n" ..
    "# Name:        main.py \n" ..
    "# Description:  \n" ..
    "# Author:       \n" ..
    "# Version:      \n" ..
    "# Date:         \n" ..
    "# \n" ..
    "from pybricks.hubs import EV3Brick \n" ..
    "from pybricks.ev3devices import (Motor, TouchSensor, ColorSensor, \n" ..
    "                                 InfraredSensor, UltrasonicSensor, GyroSensor) \n" ..
    "from pybricks.parameters import Port, Stop, Direction, Button, Color \n" ..
    "from pybricks.tools import wait, StopWatch, DataLog \n" ..
    "from pybricks.robotics import DriveBase \n" ..
    "from pybricks.media.ev3dev import SoundFile, ImageFile \n" ..
    "\n" ..
    "\n" ..
    "# Create your objects here. \n" ..
    "ev3 = EV3Brick()\n " ..
    "\n" ..
    "\n" ..
    "# Write your program here. \n" ..
    "ev3.speaker.beep()\n"
    main_file = base_projects_dir .. project_name .. '/main.py'
    f = io.open(main_file, 'w')
    f:write(micro_python_code)
    io.close(f)
end

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
    -- Create project directory, first check if directory already exists
    if isdir(project_name) then
        -- Project already exists, ask user to overwrite or not
        vim.ui.input({
            prompt = "Project already exists! Overwrite? [y,N]: "
        }, function(input)
            if input == "y" then
                -- Overwrite project_file in existing directory
                write_project_file(username, host, project_name, interpreter)
                -- Add main.py to project directory
                write_main_python()
            end
        end)
    else
       -- Project does not exist create directory and write project_file
        os.execute('mkdir ' .. project_name)
        write_project_file(username, host, project_name, interpreter)
        -- Add main.py to project directory
        if (interpreter == 'python') then
            write_main_python()
        else
            write_main_micro_python()
        end
    end
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
            user, host, interpreter = read_project_file(project_file)
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
       -- local handle = io.popen("rsync -auv -i ~/.ssh/ev3-3.pub test1 robot@192.168.2.14:/home/robot")
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

