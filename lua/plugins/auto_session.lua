vim.o.sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions"

require("auto-session").setup({
    log_level = "info",
    auto_save_enabled = true,
    auto_restore_enabled = false,
    auto_session_suppress_dirs = { "/", "~/", "~/Downloads/" },
    pre_save_cmds = { "NvimTreeClose", "SymbolsOutlineClose" },
})
