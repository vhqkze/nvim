vim.g["test#strategy"] = "neovim"
vim.g["test#neovim#start_normal"] = 1 -- If using neovim strategy
vim.g["test#python#runner"] = "pytest"

vim.keymap.set("n", "<leader>tr", "<cmd>TestNearest<cr>", { silent = true, desc = "Test Nearest" })
vim.keymap.set("n", "<leader>tf", "<cmd>TestFile<cr>", { silent = true, desc = "Test File" })
vim.keymap.set("n", "<leader>tl", "<cmd>TestLast<cr>", { silent = true, desc = "Test Last" })
vim.keymap.set("n", "<leader>tv", "<cmd>TestVisit<cr>", { silent = true, desc = "Test Visit" })
