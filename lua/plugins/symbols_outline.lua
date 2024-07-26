local outline = require("outline")

outline.setup({
    outline_window = {
        auto_close = true,
        wrap = false,
    },
    guides = {
        enabled = true,
        markers = {
            -- It is recommended for bottom and middle markers to use the same number
            -- of characters to align all child nodes vertically.
            bottom = " ",
            middle = " ",
            vertical = "▕ ",
        },
    },
    symbol_folding = {
        autofold_depth = 1,
        markers = { "", "" },
    },
    preview_window = {
        auto_preview = false,
    },
    keymaps = {
        hover_symbol = "J",
    },
    provider = {
        lsp = {
            blacklist_clients = {},
        },
    },
    symbols = {
        filter = {
            default = { exclude = true },
            python = { "Enum", "Variable", "Module", exclude = true },
        },
        icons = {
            Array         = { hl = "Constant",   icon = " " },
            Boolean       = { hl = "Boolean",    icon = " " },
            Class         = { hl = "Type",       icon = " " },
            Component     = { hl = "Function",   icon = " " },  -- TODO: fix icon
            Constant      = { hl = "Constant",   icon = " " },
            Constructor   = { hl = "Special",    icon = " " },
            Enum          = { hl = "Type",       icon = " " },
            EnumMember    = { hl = "Identifier", icon = " " },
            Event         = { hl = "Type",       icon = " " },
            Field         = { hl = "Identifier", icon = " " },
            File          = { hl = "Identifier", icon = " " },
            Fragment      = { hl = "Constant",   icon = " " },  -- TODO: fix icon
            Function      = { hl = "Function",   icon = " " },
            Interface     = { hl = "Type",       icon = " " },
            Key           = { hl = "Type",       icon = " " },
            Method        = { hl = "Function",   icon = " " },
            Module        = { hl = "Function",   icon = " " },
            Namespace     = { hl = "Include",    icon = " " },
            Null          = { hl = "Include",    icon = " " },
            Number        = { hl = "Type",       icon = " " },
            Object        = { hl = "Number",     icon = " " },
            Operator      = { hl = "Type",       icon = " " },
            Package       = { hl = "Identifier", icon = " " },
            Parameter     = { hl = "Include",    icon = " " },
            Property      = { hl = "Identifier", icon = " " },
            StaticMethod  = { hl = "Identifier", icon = " " },
            String        = { hl = "Function",   icon = " " },
            Struct        = { hl = "String",     icon = " " },
            TypeAlias     = { hl = "Structure",  icon = " " },
            TypeParameter = { hl = "Type",       icon = " " },
            Variable      = { hl = "Identifier", icon = " " },
        },
    },
})

vim.keymap.set({ "n", "i" }, "<M-7>", function()
    if outline.is_open() then
        if outline.has_focus() then
            outline.close()
        else
            outline.focus_outline()
        end
    else
        if not outline.has_provider() then
            vim.notify("No supported provider...", vim.log.levels.ERROR, { title = "Outline" })
        else
            outline.open()
        end
    end
end, { silent = true, desc = "Toggle Outline" })
