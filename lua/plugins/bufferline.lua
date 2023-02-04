require("bufferline").setup({
    options = {
        indicator = {
            style = "none",
        },
        offsets = {
            { filetype = "NvimTree", text = "File Explorer", text_align = "center", padding = 0 },
            { filetype = "undotree", text = "Undo", text_align = "center", padding = 0 },
        },
    },
})

vim.keymap.set("n", "<leader>b", "<cmd>BufferLinePick<cr>", { silent = true })
