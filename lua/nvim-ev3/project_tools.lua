-- Functionaly for writing and reading project files and creating python files
local utils = require "nvim-ev3.utils"

local M = {}

function M.write_project_file(project_file, project_name, 
                              user, host, interpreter)
    -- Write data to project file
    f = io.open(project_file, "w")
    io.output(f)
    io.write("USER=" .. user .. "\n")
    io.write("HOST=" .. host .. "\n")
    io.write("DIR=home/" .. user .. "/" .. project_name .. "\n")
    io.write("SCRIPT=main.py" .. "\n")
    io.write("INTERPRETER=" .. interpreter)
    io.close(f)
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

function M.write_main_python(base_projects_dir, project_name)
    -- Write main.py for python interpreter
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
    "                           MoveTank, MoveSteering, MoveJoystick\n" ..
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
end

function M.write_main_micro_python(base_projects_dir, project_name)
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
    main_file = base_projects_dir .. project_name .. "/main.py"
    f = io.open(main_file, "w")
    f:write(micro_python_code)
    io.close(f)
end

return M
