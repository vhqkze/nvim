require("lsp_signature").setup({
    bind = true,
    fix_pos = true,
    hi_parameter = "WarningMsg",
    handler_opts = {
        border = "rounded", -- double, rounded, single, shadow, none
    },
    toggle_key = "<D-p>",
    padding = " ",
    hint_prefix = "💡 ",
})
