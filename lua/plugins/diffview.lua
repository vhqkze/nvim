local actions = require("diffview.actions")

require("diffview").setup({
    hook = {
        diff_buf_read = function(bufnr)
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.colorcolumn = { 80 }
        end,
    },
    keymaps = {
        view = {
            { "n", "<c-n>", actions.toggle_files, { desc = "Toggle files panel" } },
        },
        file_panel = {
            { "n", "<c-n>", actions.toggle_files, { desc = "Toggle files panel" } },
        },
    },
})
