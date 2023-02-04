-- highlight on yank
local yankGrp = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    -- command = "silent! lua vim.highlight.on_yank({higroup='Search', timeout=800})",
    callback = function()
        vim.highlight.on_yank({ higroup = "Search", timeout = 800 })
    end,
    group = yankGrp,
})

-- windows to close with "q"
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "help", "qf", "lspinfo", "list", "lspsagaoutline" },
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = true })
    end,
})
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "man" },
    callback = function()
        vim.keymap.set("n", "q", "<cmd>quit<cr>", { silent = true, buffer = true })
    end,
})
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "terminal" },
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = true })
    end,
})

-- automatically jump to the last place visited
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})
