local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
local navic = require("nvim-navic")

local on_attach = function(client, bufnr)
    navic.attach(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    -- vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions

    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { silent = true, buffer = bufnr, desc = "Go to declaration" })
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { silent = true, buffer = bufnr, desc = "Go to definition" })
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, { silent = true, buffer = bufnr, desc = "Go to implementation" })
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, { silent = true, buffer = bufnr, desc = "Add workspace folder" })
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, { silent = true, buffer = bufnr, desc = "Remove workspace folder" })
    vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, { silent = true, buffer = bufnr, desc = "Show workspace folders" })
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, { silent = true, buffer = bufnr, desc = "type definition" })
    vim.keymap.set("n", "gr", vim.lsp.buf.references, { silent = true, buffer = bufnr, desc = "Go to references" })
    vim.keymap.set("n", "<space>f", function()
        vim.lsp.buf.format({ async = true })
    end, { silent = true, buffer = bufnr, desc = "lsp formatting" })
end

-- set up lspconfig + nvim_cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
-- use ufo
capabilities.textDocument.foldingRange = {
    dynamicRegistration = false,
    lineFoldingOnly = true,
}

mason_lspconfig.setup_handlers({
    function(server_name)
        lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
        })
    end,
    ["sumneko_lua"] = function()
        lspconfig.sumneko_lua.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "hs" },
                    },
                },
            },
        })
    end,
})

-- for _, server_name in pairs(require("lspconfig").util.available_servers()) do
--     lspconfig[server_name].setup({
--         on_attach = on_attach,
--         capabilities = capabilities,
--     })
-- end
-- for _, server_name in pairs(mason_lspconfig.get_installed_servers()) do
--     lspconfig[server_name].setup({
--         on_attach = on_attach,
--         capabilities = capabilities,
--     })
-- end

require("lspconfig.ui.windows").default_options.border = "rounded"

local signs = { Error = " ", Warn = " ", Info = " ", Hint = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end

vim.diagnostic.config({
    virtual_text = {
        prefix = "",
    },
})
