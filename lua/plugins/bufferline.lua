require("bufferline").setup({
    options = {
        indicator = {
            style = "none",
        },
        offsets = {
            { filetype = "NvimTree", text = "File Explorer", text_align = "center", padding = 0 },
            { filetype = "undotree", text = "Undo", text_align = "center", padding = 0 },
        },
        get_element_icon = function(element)
            local icon, hl
            local filename = vim.fn.fnamemodify(element.path, ":t")
            if filename ~= nil then
                local extension = vim.fn.fnamemodify(filename, ":e")
                icon, hl = require("nvim-web-devicons").get_icon(filename, extension, { default = false })
            end
            if icon == nil then
                icon, hl = require("nvim-web-devicons").get_icon_by_filetype(element.filetype, { default = true })
            end
            return icon, hl
        end,
        show_close_icon = false,
        always_show_bufferline = false,
    },
})

vim.keymap.set("n", "<leader>b", "<cmd>BufferLinePick<cr>", { silent = true })
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { silent = true })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { silent = true })
vim.keymap.set("n", "[B", "<cmd>BufferLineMovePrev<cr>", { silent = true })
vim.keymap.set("n", "]B", "<cmd>BufferLineMoveNext<cr>", { silent = true })
vim.keymap.set({ "n", "t" }, "[n", "<cmd>tabp<cr>", { silent = true })
vim.keymap.set({ "n", "t" }, "]n", "<cmd>tabn<cr>", { silent = true })
