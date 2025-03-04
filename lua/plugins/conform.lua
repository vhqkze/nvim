local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        bash = { "shfmt" },
        css = { "prettier" },
        go = { "gofmt" },
        graphql = { "prettier" },
        html = { lsp_format = "prefer" },
        java = { lsp_format = "prefer" },
        javascript = { "prettier" },
        json = { "prettier" },
        json5 = { "prettier" },
        jsonc = { "prettier" },
        lua = { "stylua" },
        markdown = { "markdownlint" },
        nix = { "nixpkgs_fmt" },
        python = { "yapf" },
        scss = { "prettier" },
        sh = { "shfmt" },
        swift = { "swiftformat" },
        toml = { "taplo" },
        typescript = { "prettier" },
        yaml = { "prettier" },
        zsh = { "shfmt" },
        ["*"] = { "trim_whitespace" },
    },
    default_format_opts = {
        lsp_format = "fallback",
    },
    log_level = vim.log.levels.ERROR,
    notify_on_error = true,
    notify_no_formatters = true,
})

vim.keymap.set({ "n", "x" }, "<leader>fm", function()
    conform.format({ async = true }, function(err)
        if not err then
            local mode = vim.api.nvim_get_mode().mode
            if vim.startswith(string.lower(mode), "v") then
                vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
            end
        end
    end)
end, { desc = "Format code" })

vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
