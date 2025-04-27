local normal = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
local nvim_tree_win_separator = vim.api.nvim_get_hl(0, { name = "NvimTreeWinSeparator" }).bg
local nvim_tree_padding = nvim_tree_win_separator == normal and 0 or 1

require("bufferline").setup({
    options = {
        indicator = {
            style = "none",
        },
        offsets = {
            { filetype = "NvimTree", text = "File Explorer", text_align = "center", padding = nvim_tree_padding },
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
        custom_filter = function(bufnr, bufnrs)
            if vim.bo[bufnr].buftype == "acwrite" then
                return false
            end
            if vim.bo[bufnr].buftype == "nofile" then
                if vim.bo[bufnr].bufhidden == "hide" or vim.bo[bufnr].bufhidden == "unload" then
                    return false
                end
            end
            return true
        end,
    },
})

vim.api.nvim_set_hl(0, "TabLineFill", {
    fg = vim.api.nvim_get_hl(0, { name = "TabLineFill" }).fg,
    bg = vim.api.nvim_get_hl(0, { name = "BufferLineBufferSelected" }).bg,
})

vim.keymap.set("n", "<leader>b", "<cmd>BufferLinePick<cr>", { silent = true })
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { silent = true })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { silent = true })
vim.keymap.set("n", "[B", "<cmd>BufferLineMovePrev<cr>", { silent = true })
vim.keymap.set("n", "]B", "<cmd>BufferLineMoveNext<cr>", { silent = true })
vim.keymap.set({ "n", "t" }, "[n", "<cmd>tabp<cr>", { silent = true })
vim.keymap.set({ "n", "t" }, "]n", "<cmd>tabn<cr>", { silent = true })
