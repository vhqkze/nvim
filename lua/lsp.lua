local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

vim.lsp.config("*", {
    root_markers = { ".git" },
    capabilities = capabilities,
})

vim.lsp.enable({
    "basedpyright",
    "bashls",
    "cssls",
    "eslint",
    "gopls",
    "html",
    "jdtls",
    "jsonls",
    "lemminx",
    "ltex_plus",
    "lua_ls",
    "marksman",
    "nixd",
    "pylsp",
    "rubocop",
    "sourcekit",
    "taplo",
    "ts_ls",
    "vimls",
    "yamlls",
})

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("my.lsp", {}),
    ---@param args {buf: number, data: {client_id: number}, event: string, file: string, id: number, match: string, group: number}
    callback = function(args)
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
        local bufnr = args.buf
        if client:supports_method("textDocument/documentSymbol") then
            require("nvim-navic").attach(client, bufnr)
            require("nvim-navbuddy").attach(client, bufnr)
        end
        if client:supports_method("textDocument/inlayHint") then
            vim.lsp.inlay_hint.enable(true)
        end
        if client.server_capabilities.semanticTokensProvider then
            vim.treesitter.stop(bufnr)
        end

        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { silent = true, buffer = bufnr, desc = "Go to declaration" })
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, buffer = bufnr, desc = "Go to definition" })
        vim.keymap.set("n", "gri", vim.lsp.buf.implementation, { silent = true, buffer = bufnr, desc = "Go to implementation" })
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { silent = true, buffer = bufnr, desc = "Add workspace folder" })
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { silent = true, buffer = bufnr, desc = "Remove workspace folder" })
        vim.keymap.set("n", "<leader>wl", function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, { silent = true, buffer = bufnr, desc = "Show workspace folders" })
        vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, { silent = true, buffer = bufnr, desc = "type definition" })
        vim.keymap.set("n", "grr", vim.lsp.buf.references, { silent = true, buffer = bufnr, desc = "Show references" })
        vim.keymap.set("n", "<space>f", function()
            vim.lsp.buf.format({ async = true })
        end, { silent = true, buffer = bufnr, desc = "lsp formatting" })
    end,
})

vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", {})

vim.diagnostic.config({
    virtual_text = {
        prefix = "•",
    },
    signs = {
        priority = 80,
        text = {
            [vim.diagnostic.severity.ERROR] = "",
            [vim.diagnostic.severity.WARN] = "",
            [vim.diagnostic.severity.INFO] = "",
            [vim.diagnostic.severity.HINT] = "",
        },
    },
    severity_sort = {
        reverse = false,
    },
    float = {
        source = true,
    },
})

-- Create a custom namespace. This will aggregate signs from all other
-- namespaces and only show the one with the highest severity on a
-- given line
local orig_signs_handler = vim.diagnostic.handlers.signs

vim.diagnostic.handlers.signs = {
    show = function(namespace, bufnr, _, opts)
        local diagnostics = vim.diagnostic.get(bufnr)
        local line_count = vim.api.nvim_buf_line_count(bufnr)
        local max_severity_per_line = {}
        for _, d in pairs(diagnostics) do
            if d.lnum < line_count then
                local m = max_severity_per_line[d.lnum]
                if not m or d.severity < m.severity then
                    max_severity_per_line[d.lnum] = d
                end
            end
        end
        local filtered_diagnostics = vim.tbl_filter(function(d)
            return d.namespace == namespace
        end, vim.tbl_values(max_severity_per_line))
        orig_signs_handler.show(namespace, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(namespace, bufnr)
        orig_signs_handler.hide(namespace, bufnr)
    end,
}
