require("bufferline").setup({
    options = {
        indicator = {
            style = "none",
        },
        offsets = {
            { filetype = "NvimTree", text = "File Explorer", text_align = "center", padding = 0 },
            { filetype = "undotree", text = "Undo", text_align = "center", padding = 0 },
        },
        show_close_icon = false,
        always_show_bufferline = false,
    },
})

vim.keymap.set("n", "<leader>b", "<cmd>BufferLinePick<cr>", { silent = true })
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { silent = true })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { silent = true })
vim.keymap.set("n", "[B", "<cmd>BufferLineMovePrev<cr>", { silent = true })
vim.keymap.set("n", "]B", "<cmd>BufferLineMoveNext<cr>", { silent = true })
vim.keymap.set("n", "[n", "<cmd>tabp<cr>", { silent = true })
vim.keymap.set("n", "]n", "<cmd>tabn<cr>", { silent = true })
