-- My custom commands

vim.api.nvim_create_user_command("BD", "bp|bd #", { desc = "buf delete without change layout" })
vim.api.nvim_create_user_command("BDD", "bp|bd! #", { desc = "buf delete force without change layout" })
