vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos"

local function close_windows()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local config = vim.api.nvim_win_get_config(win)
        local buf = vim.api.nvim_win_get_buf(win)
        local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })
        local need_close_buf = { "terminal", "quickfix", "nofile" }
        if vim.tbl_contains(need_close_buf, buftype) then
            vim.api.nvim_win_close(win, false)
        elseif config.relative ~= "" then -- close float window
            vim.api.nvim_win_close(win, false)
        end
    end
end

local function remove_virtual_env()
    if vim.env.VIRTUAL_ENV ~= nil then
        local env_path = vim.env.PATH
        local new_path = {}
        for _, path in pairs(vim.split(env_path, ":")) do
            if path ~= "" and not vim.startswith(path, vim.env.VIRTUAL_ENV) then
                table.insert(new_path, path)
            end
        end
        vim.env.VIRTUAL_ENV = nil
        vim.env.PATH = table.concat(new_path, ":")
    end
end

local function restore_python()
    if vim.fn.executable("poetry") == 0 then
        return
    end
    local obj = vim.system({ "poetry", "env", "info", "-p" }, { text = true }):wait()
    if obj.code ~= 0 then
        return
    end
    vim.env.VIRTUAL_ENV = vim.trim(obj.stdout)
    vim.env.PATH = vim.env.VIRTUAL_ENV .. "/bin:" .. vim.env.PATH
    -- Reconfigure pyright with the provided python path
    vim.schedule(function()
        if vim.fn.exists(":PyrightSetPythonPath") == 2 then
            vim.cmd({ cmd = "PyrightSetPythonPath", args = { vim.env.VIRTUAL_ENV .. "/bin/python" } })
        end
    end)
end

require("auto-session").setup({
    log_level = vim.log.levels.ERROR,
    auto_save = true,
    auto_restore = false,
    auto_create = function()
        local cwd = vim.uv.cwd()
        if cwd:find(vim.env.HOME .. "/.local/share/nvim/lazy/") then
            return false
        end
        local root_dir = vim.fs.root(0, { ".git", "pyproject.toml" })
        return root_dir == cwd
    end,
    suppressed_dirs = { "/", "~/", "~/Downloads/", "~/.local/share/man/", "/usr/local/share/man/", "/usr/share/man/" },
    auto_restore_last_session = false,
    bypass_save_filetypes = { "dashboard" },
    close_unsupported_windows = true,
    args_allow_single_directory = true,
    args_allow_files_auto_save = false,
    cwd_change_handling = false,
    pre_save_cmds = { close_windows },
    pre_restore_cmds = { remove_virtual_env },
    post_restore_cmds = { restore_python },
    session_lens = {
        path_display = { "smart" },
        load_on_setup = false,
        previewer = false,
    },
})
