require("notify").setup({
    top_down = false,
    max_width = 75,
    on_open = function(win)
        local bufnr = vim.fn.winbufnr(win)
        vim.api.nvim_set_option_value("wrap", true, { win = win })
        vim.keymap.set("n", "q", "<c-w>c", { silent = true, buffer = bufnr })
    end,
})

require("telescope").load_extension("notify")
