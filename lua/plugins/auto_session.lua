vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos"

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

require("auto-session").setup({
    log_level = "error",
    auto_session_create_enabled = false,
    auto_save_enabled = true,
    auto_restore_enabled = false,
    auto_session_suppress_dirs = { "/", "~/", "~/Downloads/", "~/.local/share/man/", "/usr/local/share/man/", "/usr/share/man/" },
    bypass_session_save_file_types = { "dashboard" },
    pre_save_cmds = { close_windows },
    pre_restore_cmds = {
        function()
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
        end,
    },
    post_restore_cmds = {
        function()
            local virtual_env
            vim.system({ "poetry", "env", "info", "-p" }, { text = true }, function(obj)
                if obj.code == 0 then
                    virtual_env = vim.trim(obj.stdout)
                end
            end):wait()
            if virtual_env then
                vim.env.PATH = virtual_env .. "/bin:" .. vim.env.PATH
                vim.env.VIRTUAL_ENV = virtual_env
                -- Reconfigure pyright with the provided python path
                if vim.fn.exists(":PyrightSetPythonPath") == 2 then
                    vim.cmd({ cmd = "PyrightSetPythonPath", args = { virtual_env .. "/bin/python" } })
                end
            end
        end,
    },
    session_lens = {
        path_display = { "smart" },
        load_on_setup = false,
    },
})
