require("barbecue").setup({
    attach_navic = false, -- attach navic to LSPs by yourself.
    include_buftypes = { "", "help" },
    exclude_filetypes = { "undotree", "diff", "toggleterm", "gitcommit", "crontab" },
    custom_section = function()
        local diagnostic_count = vim.diagnostic.count(0)
        local signs = { Error = " ", Warn = " ", Info = " ", Hint = " " }
        local result_error = { diagnostic_count[1] and (signs.Error .. diagnostic_count[1] .. " ") or "", "DiagnosticSignError" }
        local result_warn = { diagnostic_count[2] and (signs.Warn .. diagnostic_count[2] .. " ") or "", "DiagnosticSignWarn" }
        local result_info = { diagnostic_count[3] and (signs.Info .. diagnostic_count[3] .. " ") or "", "DiagnosticSignInfo" }
        local result_hint = { diagnostic_count[4] and (signs.Hint .. diagnostic_count[4] .. " ") or "", "DiagnosticSignHint" }
        return {
            result_error,
            result_warn,
            result_info,
            result_hint,
        }
    end,
    kinds = {
        File          = "",
        Module        = "",
        Namespace     = "",
        Package       = "",
        Class         = "",
        Method        = "",
        Property      = "",
        Field         = "",
        Constructor   = "",
        Enum          = "",
        Interface     = "",
        Function      = "",
        Variable      = "",
        Constant      = "",
        String        = "",
        Number        = "",
        Boolean       = "",
        Array         = "",
        Object        = "",
        Key           = "",
        Null          = "",
        EnumMember    = "",
        Struct        = "",
        Event         = "",
        Operator      = "",
        TypeParameter = "",
    },
})
