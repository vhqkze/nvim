local select_textobject = require("nvim-treesitter-textobjects.select").select_textobject
local swap = require("nvim-treesitter-textobjects.swap")
local move = require("nvim-treesitter-textobjects.move")
local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

require("nvim-treesitter-textobjects").setup({
    select = {
        lookahead = false,
    },
    move = {
        set_jumps = true,
    },
})

-- capture
vim.keymap.set({ "x", "o" }, "am", function()
    select_textobject("@function.outer", "textobjects")
end, { desc = "function" })
vim.keymap.set({ "x", "o" }, "im", function()
    select_textobject("@function.inner", "textobjects")
end, { desc = "inner function" })
vim.keymap.set({ "x", "o" }, "ac", function()
    select_textobject("@class.outer", "textobjects")
end, { desc = "class" })
vim.keymap.set({ "x", "o" }, "ic", function()
    select_textobject("@class.inner", "textobjects")
end, { desc = "inner class" })
vim.keymap.set({ "x", "o" }, "as", function()
    select_textobject("@local.scope", "locals")
end, { desc = "local scope" })

-- swap
vim.keymap.set("n", "<leader>a", function()
    swap.swap_next("@parameter.inner")
end, { desc = "swap next node" })
vim.keymap.set("n", "<leader>A", function()
    swap.swap_previous("@parameter.outer")
end, { desc = "swap previous node" })

-- move next
vim.keymap.set({ "n", "x", "o" }, "]m", function()
    move.goto_next_start("@function.outer", "textobjects")
end, { desc = "next function start", remap = true })
vim.keymap.set({ "n", "x", "o" }, "]a", function()
    move.goto_next_start("@class.outer", "textobjects")
end, { desc = "next class start" })

vim.keymap.set({ "n", "x", "o" }, "]o", function()
    move.goto_next_start({ "@loop.inner", "@loop.outer" }, "textobjects")
end, { desc = "next loop start" })
vim.keymap.set({ "n", "x", "o" }, "]s", function()
    move.goto_next_start("@local.scope", "locals")
end, { desc = "next local scope start" })

vim.keymap.set({ "n", "x", "o" }, "]M", function()
    move.goto_next_end("@function.outer", "textobjects")
end, { desc = "next function stop" })
vim.keymap.set({ "n", "x", "o" }, "]A", function()
    move.goto_next_end("@class.outer", "textobjects")
end, { desc = "next class stop" })

-- move previous
vim.keymap.set({ "n", "x", "o" }, "[m", function()
    move.goto_previous_start("@function.outer", "textobjects")
end, { desc = "previous function start" })
vim.keymap.set({ "n", "x", "o" }, "[a", function()
    move.goto_previous_start("@class.outer", "textobjects")
end, { desc = "previous class start" })

vim.keymap.set({ "n", "x", "o" }, "[o", function()
    move.goto_previous_start({ "@loop.inner", "@loop.outer" }, "textobjects")
end, { desc = "previous loop start" })
vim.keymap.set({ "n", "x", "o" }, "[s", function()
    move.goto_previous_start("@local.scope", "locals")
end, { desc = "previous local scope start" })

vim.keymap.set({ "n", "x", "o" }, "[M", function()
    move.goto_previous_end("@function.outer", "textobjects")
end, { desc = "previous function stop" })
vim.keymap.set({ "n", "x", "o" }, "[A", function()
    move.goto_previous_end("@class.outer", "textobjects")
end, { desc = "previous class stop" })

-- Go to either the start or the end, whichever is closer.
vim.keymap.set({ "n", "x", "o" }, "]d", function()
    move.goto_next("@conditional.outer", "textobjects")
end, { desc = "next conditional" })
vim.keymap.set({ "n", "x", "o" }, "[d", function()
    move.goto_previous("@conditional.outer", "textobjects")
end, { desc = "previous conditional" })

-- Repeat movement with ; and ,
-- ensure ; goes forward and , goes backward regardless of the last direction
vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
vim.keymap.set({ "n", "x", "o" }, "<leader>,", ts_repeat_move.repeat_last_move_previous)
