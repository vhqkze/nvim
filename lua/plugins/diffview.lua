local actions = require("diffview.actions")

require("diffview").setup({
    watch_index = false,
    view = {
        default = {
            disable_diagnostics = true,
        },
        file_history = {
            disable_diagnostics = true,
        },
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
