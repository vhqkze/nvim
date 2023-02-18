-- It is useless to write no_default_mapping here. It needs to be written before the plugin is loaded.
-- vim.g.sandwich_no_default_key_mappings = 1
-- vim.g.operator_sandwich_no_default_key_mappings = 1
-- vim.g.textobj_sandwich_no_default_key_mappings = 1
vim.fn["operator#sandwich#set"]("all", "all", "hi_duration", 1000)
vim.g["operator#sandwich#persistent_highlight"] = "glow"

vim.keymap.set({ "n", "x", "o" }, "<leader>sa", "<Plug>(sandwich-add)", { silent = true })

vim.keymap.set({ "n", "x" }, "<leader>sd", "<Plug>(sandwich-delete)", { silent = true })
vim.keymap.set("n", "<leader>sdb", "<Plug>(sandwich-delete-auto)", { silent = true })

vim.keymap.set({ "n", "x" }, "<leader>sr", "<Plug>(sandwich-replace)", { silent = true })
vim.keymap.set("n", "<leader>srb", "<Plug>(sandwich-replace-auto)", { silent = true })
