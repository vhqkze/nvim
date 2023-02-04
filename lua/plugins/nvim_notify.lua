require("notify").setup({
    on_open = function(win)
        vim.api.nvim_win_set_option(win, "wrap", true)
    end,
})

require("telescope").load_extension("notify")
