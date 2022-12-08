-- Command :EV3_CreateProject
local M = {}

function M.create_ev3_project()
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
    -- Create project directory
    os.execute('mkdir ' .. project_name)
    -- TODO check if directory already exists, then what??

    -- Write data to project file
    local project_file = io.open(project_name .. '/' .. '.project.ini', 'w')
    io.output(project_file)
    io.write('USER=' .. username .. '\n')
    io.write('HOST=' .. host .. '\n')
    io.write('DIR=home/' .. username .. '/' .. project_name .. '\n')
    io.write('SCRIPT=main.py')
    io.close(project_file)

end

function M.upload_ev3_project()
    -- Upload project to EV3
    print("Upload project to EV3")
end

function M.run_ev3_project()
    -- Run project on EV3 device
    print("Run project on EV3 device")
end

return M
