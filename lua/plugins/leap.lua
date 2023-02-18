require("leap").setup({})

require("leap").add_default_mappings()

-- vim.keymap.set("n", "s", "<Plug>(leap-forward-to)", { silent = true })
-- vim.keymap.set("n", "S", "<Plug>(leap-backward-to)", { silent = true })
-- vim.keymap.set({ "x", "o" }, "s", function ()
--     require("leap").leap({offset=1, inclusive_op=true})
-- end, { silent = true })
--
-- vim.keymap.set({ "x", "o" }, "S", function ()
--     require("leap").leap({backward=true})
-- end, { silent = true })
-- vim.keymap.set("n", "gs", "<Plug>(leap-from-window)", { silent = true })
