vim.g.neoformat_json_prettier = {
    exe = "prettier",
    args = { "--stdin-filepath", '"%:p"', "--parser", "json" },
    stdin = 1,
}
vim.g.neoformat_html_prettier = {
    exe = "prettier",
    args = { "--stdin-filepath", '"%:p"', "--parser", "html" },
    stdin = 1,
}
vim.g.neoformat_javascript_prettier = {
    exe = "prettier",
    args = { "--stdin-filepath", '"%:p"', "--parser", "javascript" },
    stdin = 1,
}
vim.g.neoformat_lua_stylua = {
    exe = "stylua",
    args = { "--search-parent-directories", "--stdin-filepath", '"%:p"', "--", "-" },
    stdin = 1,
    replace = 0,
}

vim.g.neoformat_enabled_lua = { "stylua" }

-- mapping
-- vim.keymap.set({ "n", "x" }, "<leader>fm", "<cmd>Neoformat<cr>", { noremap = true, silent = true, desc = "Format" })
