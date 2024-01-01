require("barbecue").setup({
    attach_navic = false, -- attach navic to LSPs by yourself.
    include_buftypes = { "", "help" },
    exclude_filetypes = { "undotree", "diff", "toggleterm", "gitcommit", "crontab" },
    custom_section = function()
        local diagnostics = vim.diagnostic.get(0)
        local diagnostic = {
            Error = 0,
            Warn = 0,
            Info = 0,
            Hint = 0,
        }
        for _, d in ipairs(diagnostics) do
            if d.severity == 1 then
                diagnostic.Error = diagnostic.Error + 1
            elseif d.severity == 2 then
                diagnostic.Warn = diagnostic.Warn + 1
            elseif d.severity == 3 then
                diagnostic.Info = diagnostic.Info + 1
            elseif d.severity == 4 then
                diagnostic.Hint = diagnostic.Hint + 1
            end
        end
        local signs = { Error = " ", Warn = " ", Info = " ", Hint = " " }
        local result_error = { diagnostic.Error > 0 and (signs.Error .. diagnostic.Error .. " ") or "", "DiagnosticSignError" }
        local result_warn = { diagnostic.Warn > 0 and (signs.Warn .. diagnostic.Warn .. " ") or "", "DiagnosticSignWarn" }
        local result_info = { diagnostic.Info > 0 and (signs.Info .. diagnostic.Info .. " ") or "", "DiagnosticSignInfo" }
        local result_hint = { diagnostic.Hint > 0 and (signs.Hint .. diagnostic.Hint .. " ") or "", "DiagnosticSignHint" }
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
