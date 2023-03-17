require("notify").setup({
    top_down = false,
    max_width = 75,
    on_open = function(win)
        local bufnr = vim.fn.winbufnr(win)
        vim.api.nvim_win_set_option(win, "wrap", true)
        vim.keymap.set("n", "q", "<c-w>c", { silent = true, buffer = bufnr })
    end,
})

require("telescope").load_extension("notify")
