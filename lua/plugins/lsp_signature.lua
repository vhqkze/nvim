require("lsp_signature").setup({
    bind = true,
    fix_pos = true,
    hi_parameter = "LspSignatureActiveParameter",
    handler_opts = {
        border = "rounded", -- double, rounded, single, shadow, none
    },
    toggle_key = "<c-s>",
    padding = " ",
    hint_enable = false,
    hint_prefix = "💡 ",
})
