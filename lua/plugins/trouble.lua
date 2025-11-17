require("trouble").setup({
    focus = true,
    modes = {
        diagnostics = {
            mode = "diagnostics",
            preview = {
                type = "split",
                relative = "win",
                position = "right",
                size = 0.6,
            },
        },
        symbols = {
            focus = true,
            win = {
                position = "right",
                size = 0.25,
            },
            preview = {
                type = "main",
            },
        },
    },
    -- stylua: ignore
    icons = {
        indent = {
            fold_open   = " ",
            fold_closed = " ",
        },
        kinds = {
            Array         = " ",
            Boolean       = " ",
            Class         = " ",
            Constant      = " ",
            Constructor   = " ",
            Enum          = " ",
            EnumMember    = " ",
            Event         = " ",
            Field         = " ",
            File          = " ",
            Function      = " ",
            Interface     = " ",
            Key           = " ",
            Method        = " ",
            Module        = " ",
            Namespace     = " ",
            Null          = " ",
            Number        = " ",
            Object        = " ",
            Operator      = " ",
            Package       = " ",
            Property      = " ",
            String        = " ",
            Struct        = " ",
            TypeParameter = " ",
            Variable      = " ",
        },
    },
})

vim.keymap.set("n", "<leader>tr", "<cmd>Trouble diagnostics toggle<cr>", { silent = true })
