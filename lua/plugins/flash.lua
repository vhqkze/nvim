local flash = require("flash")

flash.setup({
    search = {
        mode = "search",
    },
    jump = {
        nohlsearch = true,
    },
    modes = {
        search = {
            enabled = false,
        },
        char = {
            config = function(opts)
                -- disable jump labels and autohide when in operator-pending mode or using a count
                if vim.fn.mode(true):find("no") or vim.v.count > 0 then
                    opts.jump_labels = false
                    opts.autohide = true
                else
                    opts.jump_labels = true
                    opts.autohide = false
                end
            end,
            autohide = false,
            jump_labels = true,
            highlight = { backdrop = false },
            search = { wrap = true },
        },
    },
})

vim.keymap.set({ "n", "x", "o" }, "s", flash.jump, { silent = true, desc = "Flash" })
vim.keymap.set({ "n", "x", "o" }, "S", flash.treesitter, { silent = true, desc = "Flash Treesitter" })
vim.keymap.set({ "o" }, "r", flash.remote, { silent = true, desc = "Remote Flash" })
vim.keymap.set({ "x", "o" }, "R", flash.treesitter_search, { silent = true, desc = "Flash Treesitter Search" })
vim.keymap.set("c", "<c-s>", flash.toggle, { silent = true, desc = "Toggle Flash Search" })
