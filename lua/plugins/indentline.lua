require("indent_blankline").setup({
    char = '▏',
    context_char = '▏',
    show_current_context = true,
    show_current_context_start = true,
    filetype_exclude = {
        "lspinfo",
        "packer",
        "checkhealth",
        "help",
        "man",
        "startify",
        "NvimTree",
        "vista",
        "Outline",
        "mason.nvim",
        "lspsagaoutline",
        "undotree",
    },
    buftype_exclude = {
        "terminal",
        "nofile",
    },
})
