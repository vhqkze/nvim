vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,globals"

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

local function rename_terminal_tab(session_name)
    local display_name = session_name:match("([^/]+)$")
    if vim.env.TMUX then
        vim.system({ "tmux", "rename-window", display_name })
    elseif vim.env.SSH_CONNECTION then
        return
    elseif vim.env.KITTY_WINDOW_ID then
        vim.system({ "kitten", "@", "set-tab-title", display_name })
    elseif vim.env.WEZTERM_EXECUTABLE then
        vim.system({ "wezterm", "cli", "set-tab-title", display_name })
    end
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
    post_restore_cmds = { rename_terminal_tab },
    session_lens = {
        path_display = { "absolute" },
        load_on_setup = false,
        previewer = false,
    },
})
