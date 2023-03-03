require("nvim-tree").setup({
    view = {
        width = 45,
    },
    sync_root_with_cwd = true,
    filters = {
        custom = {
            "\\.DS_Store",
            "__pycache__",
        },
    },
    renderer = {
        icons = {
            git_placement = "signcolumn",
            glyphs = {
                default = "",
            },
        },
    },
    actions = {
        open_file = {
            quit_on_open = true,
        },
        change_dir = {
            enable = true,
            global = true,
        },
    },
    update_focused_file = {
        enable = true,
    },
})

vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { silent = true })
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFindFile<cr>", { silent = true })
vim.keymap.set("n", "<leader>to", "<cmd>NvimTreeOpen<cr>", { silent = true })
