-- Functionaly for writing and reading project files and creating python files
local utils = require "nvim-ev3.utils"

local M = {}

function M.ask_project_name()
    -- Ask user for and return project Name
    result = nill
    vim.ui.input({
        prompt = "Enter project name: ",
    }, function(input)
        if input then
            -- User did enter a name
            result = input
        else
            -- User did not enter anything, just pressed enter 
            print("You need to enter a project name to create a new project.")
        end
    end)
    return result
end

function M.ask_username()
    -- Ask and return username
    result = nill
    vim.ui.input({
        prompt = "Enter username: ",
        default = "robot",
    }, function(input)
        if input then
            result = input
        end
    end)
    return result
end

function M.ask_hostname()
    -- Ask and return hostname
    result = nill
    vim.ui.input({
        prompt = "Enter host: ",
    }, function(input)
        if input then
            result = input
        end
    end)
    return result
end

function M.ask_interpreter()
    -- Ask and return interpreter
    result = nill
    vim.ui.input({
        prompt = "Choose interpreter: 1=python, 2=micro-python: ",
        default = 2
    }, function(input)
        if input == "1" then
            result = "python"
        else
            result = "micro-python"
        end
    end)
    return result
end

function M.write_project_file(project_file, project_name, 
                              user, host, interpreter)
    -- Write data to project file
    f = io.open(project_file, "w")
    io.output(f)
    if not user then
        user = ""
    end
    if not host then
        host = ""
    end
    f:write("USER=" .. user .. "\n")
    f:write("HOST=" .. host .. "\n")
    f:write("DIR=home/" .. user .. "/" .. project_name .. "\n")
    f:write("SCRIPT=main.py" .. "\n")
    f:write("INTERPRETER=" .. interpreter)
    close(f)
end

function M.read_project_file(project_file)
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

function M.write_main_file(interpreter, base_projects_dir, project_name)
    -- Write new main.py
    if interpreter == "python" then
        python_code = 
        "#!/user/bin/env python3 \n" ..
        "# \n" ..
        "# Name:        main.py \n" ..
        "# Description:  \n" ..
        "# Author:       \n" ..
        "# Version:      \n" ..
        "# Date:         \n" ..
        "# \n" ..
        "from ev3dev2.motor import (LargeMotor, MediumMotor,\n" ..
        "                           MoveTank, MoveSteering, MoveJoystick,\n" ..
        "                           OUTPUT_A, OUTPUT_B, OUTPUT_C, OUTPUT_D)\n" ..
        "from ev3dev2.sensor import INPUT_1, INPUT_2, INPUT_3, INPUT_4\n" ..
        "from ev3dev2.sensor.lego import (TouchSensor, ColorSensor,\n" ..
        "                                 UltrasonicSensor, InfraredSensor)\n" ..
        "from ev3dev2.led import Leds\n" ..
        "from ev3dev2.button import Button\n" ..
        "from ev3dev2.sound import Sound\n" ..
        "from ev3dev2.display import Display\n" ..
        "\n"
        main_file = base_projects_dir .. project_name .. "/main.py"
        f = io.open(main_file, "w")
        f:write(python_code)
        io.close(f)
    else
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
        main_file = base_projects_dir .. project_name .. "/main.py"
        f = io.open(main_file, "w")
        f:write(micro_python_code)
        io.close(f)
    end
end

return M
