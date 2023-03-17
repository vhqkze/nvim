---get highligh color
---@param name string highlight name
---@param key? string background, foreground, special, italic, underline, bold, undercurl, strikethrough
local function get_hl(name, key)
    local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
    if ok then
        if key == nil then
            return hl
        else
            local value = hl[key]
            if type(value) == "number" then
                return string.format("#%06x", value)
            else
                return value
            end
        end
    end
    return nil
end

local barbecue_background = get_hl("StatusLine", "background")
vim.api.nvim_set_hl(0, "BarbecueDiagnosticError", { fg = get_hl("DiagnosticSignError", "foreground"), bg = barbecue_background })
vim.api.nvim_set_hl(0, "BarbecueDiagnosticWarn", { fg = get_hl("DiagnosticSignWarn", "foreground"), bg = barbecue_background })
vim.api.nvim_set_hl(0, "BarbecueDiagnosticInfo", { fg = get_hl("DiagnosticSignInfo", "foreground"), bg = barbecue_background })
vim.api.nvim_set_hl(0, "BarbecueDiagnosticHint", { fg = get_hl("DiagnosticSignHint", "foreground"), bg = barbecue_background })

require("barbecue").setup({
    attach_navic = false, -- attach navic to LSPs by yourself.
    theme = {
        normal = { bg = barbecue_background },
    },
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
        local signs = { Error = " ", Warn = " ", Info = " ", Hint = " " }
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
