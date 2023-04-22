local util = require("util")

local barbecue_background = util.get_hl("StatusLine", "bg#")
vim.api.nvim_set_hl(0, "BarbecueDiagnosticError", { fg = util.get_hl("DiagnosticSignError", "fg#"), bg = barbecue_background })
vim.api.nvim_set_hl(0, "BarbecueDiagnosticWarn", { fg = util.get_hl("DiagnosticSignWarn", "fg#"), bg = barbecue_background })
vim.api.nvim_set_hl(0, "BarbecueDiagnosticInfo", { fg = util.get_hl("DiagnosticSignInfo", "fg#"), bg = barbecue_background })
vim.api.nvim_set_hl(0, "BarbecueDiagnosticHint", { fg = util.get_hl("DiagnosticSignHint", "fg#"), bg = barbecue_background })

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
        local result_error = { diagnostic.Error > 0 and (signs.Error .. diagnostic.Error .. " ") or "", "BarbecueDiagnosticError" }
        local result_warn = { diagnostic.Warn > 0 and (signs.Warn .. diagnostic.Warn .. " ") or "", "BarbecueDiagnosticWarn" }
        local result_info = { diagnostic.Info > 0 and (signs.Info .. diagnostic.Info .. " ") or "", "BarbecueDiagnosticInfo" }
        local result_hint = { diagnostic.Hint > 0 and (signs.Hint .. diagnostic.Hint .. " ") or "", "BarbecueDiagnosticHint" }
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
