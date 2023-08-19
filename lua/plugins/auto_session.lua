vim.o.sessionoptions = "blank,buffers,curdir,help,tabpages,winsize,winpos,terminal"

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
    log_level = "info",
    auto_save_enabled = true,
    auto_restore_enabled = false,
    auto_session_suppress_dirs = { "/", "~/", "~/Downloads/", "~/.local/share/man/", "/usr/local/share/man/", "/usr/share/man/" },
    pre_save_cmds = { close_windows },
    session_lens = {
        load_on_setup = false,
    },
})
