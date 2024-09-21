local dirname = ""
local lazypath = vim.fn.stdpath("data") .. "/lazy"
dirname = string.format("%s:s?%s?%s?", dirname, lazypath, "[PLUGIN]")
dirname = string.format("%s:s?%s?%s?", dirname, vim.env.VIM, "$VIM")
dirname = string.format("%s:s?%s?%s?", dirname, vim.uv.fs_realpath(vim.env.TMPDIR), "$TMPDIR")
dirname = dirname .. ":~:."

require("barbecue").setup({
    attach_navic = false, -- attach navic to LSPs by yourself.
    include_buftypes = { "", "help" },
    exclude_filetypes = { "undotree", "diff", "toggleterm", "gitcommit", "crontab" },
    theme = "tokyonight",
    modifiers = {
        dirname = dirname,
    },
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

vim.api.nvim_create_autocmd({ "TermOpen", "FileType" }, {
    callback = function(args)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == args.buf then
                vim.schedule(function()
                    pcall(require("barbecue.ui").update, win)
                end)
                return
            end
        end
    end,
})
