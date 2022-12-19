-- Local helper functions

local function exists(file)
   local ok, err, code = os.rename(file, file)
   if not ok then
      if code == 13 then
         -- Permission denied, but it exists
         return true
      end
   end
   return ok, err
end

local function isdir(path)
    return exists(path .. "/")
end

function split_string (inputstr, sep)
   if sep == nil then
      sep = "%s"
   end
   local t={}
   for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
   end
   return t
end

-- Public functions

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
    line = split_string(line, "=")
    user = line[2]
    -- Read host
    line = f:read("*l")
    line = split_string(line, "=")
    host = line[2]
    -- Read interpreter, first read lines with dir and SCRIPT
    line = f:read("*l")
    line = f:read("*l")
    line = f:read("*l")
    line = split_string(line, "=")
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
            write_main_python()
            -- TODO add function write_main_micro-python()
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
    if (interpreter == 'python') then
        os.execute('ssh ' .. user .. '@' .. host  .. ' python3 /home/' ..
                   user .. '/' .. project_name .. '/main.py')
    else
        os.execute('ssh ' .. user .. '@' .. host  ..
                   ' brickrun -r -- pybricks-micropython /home/' ..
                   user .. '/' .. project_name .. '/main.py')
    end
end

return M
