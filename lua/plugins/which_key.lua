local wk = require("which-key")

wk.setup({
    preset = "classic",
    plugins = {
        spelling = {
            enabled = true,
            suggestions = 20,
        },
    },
    ---@param ctx { mode: string, operator: string }
    defer = function(ctx)
        return ctx.mode == "V" or ctx.mode == "<C-V>" or ctx.mode == "v"
    end,
    icons = {
        separator = " ",
    },
})

wk.add({
    { "<leader>f", group = "file" },
    { "<leader>h", group = "Gitsigns" },
})
