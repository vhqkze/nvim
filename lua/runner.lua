local module_name = "Runner"
local require_toggleterm, toggleterm = pcall(require, "toggleterm.terminal")
if not require_toggleterm then
    vim.notify("Runner need install toggleterm.nvim first!", vim.log.levels.ERROR, { title = module_name })
end
local Terminal = toggleterm.Terminal
local levels = vim.log.levels
local last_command = nil
local M = {}
M.runner = nil

M.config = {
    debug = false,
    default = {
        open_term = true,
        hidden = true,
        notify = true, -- for shell command
        root_pattern = { ".git" },
        focus = true,
        ---@type string|fun(cmd: string): string
        display_name = function(cmd)
            return cmd:match("^%S+")
        end,
        direction = "horizontal",
        ---@type table<string, string>
        env = nil,
        clear_env = false,
        start_in_insert = false,
    },
    system_notify = {
        enable = true,
        min_second = 10,
    },
}

--- send notify
---@param msg string
---@param level? integer
local function notify(msg, level)
    local min_level = M.config.debug and levels.DEBUG or levels.INFO
    level = level or levels.INFO
    if level >= min_level then
        vim.notify(msg, level, { title = module_name })
    end
end

-- variable
-- cwd = ~/Developer/nvim
-- file = lua/plugins/toggleterm.lua
-- $dir                 /Users/xxxxxx/Developer/nvim/lua/plugins
-- $file                /Users/xxxxxx/Developer/nvim/lua/plugins/toggleterm.lua
-- $fileName            toggleterm.lua
-- $fileNameWithoutExt  toggleterm
-- $relateFile          lua/plugins/toggleterm.lua

---@class cmdOpts
---@field cmd string
---@field open_term? boolean default: true
---@field hidden? boolean default: true
---@field notify? boolean
---@field dir? string if dir is nil or empty, will be set by root_pattern
---@field root_pattern? string[] default: {".git"}
---@field focus? boolean default: false
---@field display_name? string
---@field direction? string default: "horizontal"
---@field env? table<string, string>
---@field clear_env? boolean default: false
---@field start_in_insert? boolean default: false

---:help lua-patterns
---@see https://www.lua.org/pil/20.2.html
---@type table<string, string|cmdOpts>
M.file = {
    ["/yabairc$"] = { cmd = "yabai --restart-service", open_term = false },
    ["/sketchybarrc$"] = { cmd = "brew services restart sketchybar", open_term = false },
    ["/skhdrc$"] = { cmd = "skhd --restart-service", open_term = false },
    ["/test_.*%.py$"] = {
        cmd = "pytest $file",
        root_pattern = { "pyproject.toml", "pytest.ini", ".pytest.ini", "tox.ini", "setup.cfg", ".git" },
        focus = false,
    },
    ["/nvim/.*%.lua$"] = ":luafile %",
}
---@type table<string, string|cmdOpts>
M.filetype = {
    asciidoc = ":AsciiDocPreview",
    bash = "bash $file",
    go = "go run $file",
    html = "open $file",
    java = "javac $relateFile && java $(echo $relateFile | sed 's/\\.java$//' | sed 's|/|.|g')",
    javascript = "node $file",
    lua = "lua $file",
    markdown = ":MarkdownPreview",
    perl = "perl $file",
    python = { cmd = "python3 -u $file", focus = false },
    rust = "rustc $file && $fileNameWithoutExt",
    sh = "bash $file",
    swift = "swift $file",
    typescript = "deno run $file",
    vim = ":source %",
    zsh = "zsh $file",
}

--- get command by filename or filetype
---@return cmdOpts|nil
local function get_command()
    local filename = vim.api.nvim_buf_get_name(0)
    for pattern, cmd in pairs(M.file) do
        if filename:find(pattern) then
            if type(cmd) == "string" then
                return { cmd = cmd }
            else
                return vim.deepcopy(cmd)
            end
        end
    end
    local filetype = vim.bo.filetype
    local cmd = M.filetype[filetype]
    if type(cmd) == "string" then
        return { cmd = cmd }
    elseif type(cmd) == "table" then
        return vim.deepcopy(cmd)
    else
        return nil
    end
end

---@param marker string[]
---@return string|nil
local function get_root_dir(marker)
    local root_dir = vim.fs.root(0, marker)
    return root_dir or vim.uv.cwd()
end

--- get file full path, if filename is empty, create a temp file
---@return string
local function get_full_path()
    local fileName = vim.api.nvim_buf_get_name(0)
    if fileName == "" then
        local content = vim.api.nvim_buf_get_lines(0, 0, -1, true)
        fileName = vim.fn.tempname()
        vim.fn.writefile(content, fileName)
    end
    return fileName
end

---@param cmd cmdOpts
---@return cmdOpts
local function substitute(cmd)
    local default = M.config.default
    cmd.root_pattern = vim.F.if_nil(cmd.root_pattern, default.root_pattern)
    if cmd.dir == nil or cmd.dir == "" then
        cmd.dir = get_root_dir(cmd.root_pattern)
    end
    local cmd_string = cmd.cmd

    local file_fullpath = get_full_path()
    local fileNameWithoutExt = vim.fn.fnamemodify(file_fullpath, ":t:r:S")
    local fileName = vim.fn.fnamemodify(file_fullpath, ":t:S")
    local dir = vim.fn.fnamemodify(file_fullpath, ":p:h:S")
    local file = vim.fn.shellescape(file_fullpath)
    local relateFile = file
    if vim.startswith(file_fullpath, cmd.dir .. "/") then
        relateFile = vim.fn.shellescape(file_fullpath:sub(#cmd.dir + 2))
    end

    cmd_string = cmd_string:gsub("%$fileNameWithoutExt", fileNameWithoutExt)
    cmd_string = cmd_string:gsub("%$fileName", fileName)
    cmd_string = cmd_string:gsub("%$file", file)
    cmd_string = cmd_string:gsub("%$dir", dir)
    cmd_string = cmd_string:gsub("%$relateFile", relateFile)
    cmd.cmd = cmd_string
    return cmd
end

---@param cmd cmdOpts
---@return cmdOpts
local function set_default(cmd)
    local default = M.config.default
    cmd.open_term = vim.F.if_nil(cmd.open_term, default.open_term)
    cmd.hidden = vim.F.if_nil(cmd.hidden, default.hidden)
    cmd.notify = vim.F.if_nil(cmd.notify, default.notify)
    cmd.root_pattern = vim.F.if_nil(cmd.root_pattern, default.root_pattern)
    if cmd.dir == nil or cmd.dir == "" then
        cmd.dir = get_root_dir(cmd.root_pattern)
    end
    cmd.focus = vim.F.if_nil(cmd.focus, default.focus)
    if cmd.display_name == nil then
        local display_name = default.display_name
        if type(display_name) == "function" then
            cmd.display_name = display_name(cmd.cmd)
        elseif type(display_name) == "string" then
            cmd.display_name = display_name
        end
    end
    cmd.direction = vim.F.if_nil(cmd.direction, default.direction)
    cmd.env = vim.F.if_nil(cmd.env, default.env)
    cmd.clear_env = vim.F.if_nil(cmd.clear_env, default.clear_env)
    cmd.start_in_insert = vim.F.if_nil(cmd.start_in_insert, default.start_in_insert)
    return cmd
end

--- run vim command
---@param cmd cmdOpts
local function run_vim_command(cmd)
    local cmd_string = cmd.cmd:sub(2)
    local ok, result = pcall(vim.api.nvim_exec2, cmd_string, { output = true })
    if not ok then
        notify(result, levels.ERROR)
    else
        notify(result.output, levels.INFO)
    end
end

--- toggle terminal
---@param state? boolean target state
function M.toggle(state)
    if M.runner ~= nil then
        local is_open = M.runner:is_open()
        if state == true and not is_open then
            M.runner:open()
        elseif state == false and is_open then
            M.runner:close()
        elseif state == nil then
            M.runner:toggle()
        end
    end
end

--- run shell command via toggleterm
---@param cmd cmdOpts
local function run_shell_command(cmd)
    if M.runner ~= nil and M.runner:is_open() then
        M.runner:shutdown()
    end
    local current_window = vim.api.nvim_get_current_win()
    local cmd_start = os.time()
    M.runner = Terminal:new({
        cmd = cmd.cmd,
        hidden = cmd.hidden,
        display_name = cmd.display_name,
        dir = cmd.dir,
        direction = cmd.direction,
        env = cmd.env,
        clear_env = cmd.clear_env,
        close_on_exit = false,
        on_open = function(term)
            term:set_mode(cmd.start_in_insert and "i" or "n")
        end,
        on_exit = function(term, job, exit_code, name)
            local duration = os.time() - cmd_start
            local need_notify = M.config.system_notify.enable and duration >= M.config.system_notify.min_second
            if not term:is_open() or need_notify then
                local msg = exit_code == 0 and "Success: " or "Failure: "
                msg = msg .. cmd.cmd
                local level = exit_code == 0 and levels.INFO or levels.ERROR
                notify(msg, level)
                require("utils").system_notify(msg, module_name)
            end
        end,
    })
    if cmd.open_term then
        M.runner:open()
        if not cmd.focus then
            vim.api.nvim_set_current_win(current_window)
        end
    else
        M.runner:spawn()
    end
    return M.runner
end

function M.run_file()
    local command = get_command()
    if command == nil then
        notify("no command found", levels.WARN)
        return
    end
    command = substitute(command)
    command = set_default(command)
    last_command = command
    if command.cmd:sub(1, 1) == ":" then
        run_vim_command(command)
    else
        run_shell_command(command)
    end
end

function M.run_last_command()
    if last_command == nil then
        notify("no last command found", levels.WARN)
        return
    end
    if last_command.cmd:sub(1, 1) == ":" then
        run_vim_command(last_command)
    else
        run_shell_command(last_command)
    end
end

return M
