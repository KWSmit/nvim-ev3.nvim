-- utils: helper functions for nvim-ev3.nvim

local M = {}

function M.get_os()
    -- Check on which operating system nvim is running

    -- Ask jit first
    if jit then
        return jit.os
    end

    -- Unix, linux variants
    local fh, err = assert(io.popen("uname -o 2>/dev/null", "r"))
    if fh then
        osname = rh:read()
    else
        osname = "Windows"
    end

    return osname
end

function M.exists(file)
    -- Check if file exists
    local ok, err, code = os.rename(file, file)
    if not ok then
       if code == 13 then
          -- Permission denied, but it exists
          return true
       end
    end
    return ok, err
end

--[[
function M.isdir(path)
    -- Check if path is valid
    return M.exists(path .. "/")
end
--]]
--
function M.is_project(dir)
    -- Check if project already exists
    project_exists = false
    -- Get all project names (dirs in projects directory)
    dir_list = M:list_projects()
    -- Check of dir is in list of projects
    for i, project_name in ipairs(dir_list) do
        if project_name == dir then
            -- Project name already used
            print(project_name)
            project_exists = true
            break
        end
    end
    return project_exists
end
--

function M.list_projects()
    -- List all existing projects
    dir_list = {}
    os = M:get_os()
    if os == "Windows" then
        for dir in io.popen("dir /d/b"):lines() do
            table.insert(dir_list, vim.fn.fnamemodify(dir, ":t"))
        end
    else
        for dir in io.popen("ls -d *"):lines() do
            table.insert(dir_list, vim.fn.fnamemodify(dir, ":t"))
        end
    end
    return dir_list
end

function M.Set (list)
  local set = {}
  for _, l in ipairs(list) do set[l] = true end
  return set
end

function M.split_string (inputstr, sep)
    -- Split string on given seperator
    if sep == nil then
       sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
       table.insert(t, str)
    end
    return t
end

return M
