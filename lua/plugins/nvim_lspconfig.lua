local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
local navic = require("nvim-navic")
local navbuddy = require("nvim-navbuddy")

---See https://www.reddit.com/r/neovim/comments/108tjy0/comment/j42cod9/?utm_source=share&utm_medium=web2x&context=3
local function filter(arr, func)
    -- Filter in place
    -- https://stackoverflow.com/questions/49709998/how-to-filter-a-lua-array-inplace
    local new_index = 1
    local size_orig = #arr
    for old_index, v in ipairs(arr) do
        if func(v, old_index) then
            arr[new_index] = v
            new_index = new_index + 1
        end
    end
    for i = new_index, size_orig do
        arr[i] = nil
    end
end

local function pyright_accessed_filter(diagnostic)
    -- Allow kwargs to be unused, sometimes you want many functions to take the
    -- same arguments but you don't use all the arguments in all the functions,
    -- so kwargs is used to suck up all the extras
    -- if diagnostic.message == '"kwargs" is not accessed' then
    -- 	return false
    -- end
    --
    -- Allow variables starting with an underscore
    -- if string.match(diagnostic.message, '"_.+" is not accessed') then
    -- 	return false
    -- end

    -- For all messages "is not accessed"
    if string.match(diagnostic.message, '".+" is not accessed') then
        return false
    end
    if string.match(diagnostic.message, 'Analysis of function ".+" is skipped because it is unannotated') then
        return false
    end

    return true
end

local function custom_on_publish_diagnostics(a, params, client_id, c, config)
    filter(params.diagnostics, pyright_accessed_filter)
    vim.lsp.diagnostic.on_publish_diagnostics(a, params, client_id, c, config)
end

local on_attach = function(client, bufnr)
    if client.name == "pylsp" then
        client.server_capabilities.documentSymbolProvider = false
    end
    if client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
        navbuddy.attach(client, bufnr)
    end
    if client.server_capabilities.inlayHintProvider then
        vim.lsp.inlay_hint.enable(bufnr, true)
    end
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
    ["lua_ls"] = function()
        lspconfig.lua_ls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "hs" },
                    },
                    hint = {
                        enable = true,
                    },
                    workspace = {
                        checkThirdParty = false
                    }
                },
            },
        })
    end,
    ["pyright"] = function()
        lspconfig.pyright.setup({
            on_attach = function(client, bufnr)
                vim.keymap.set("n", "<leader>o", "<cmd>PyrightOrganizeImports<cr>", { silent = true, buffer = bufnr, desc = "Organize Imports" })
                vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(custom_on_publish_diagnostics, {})
                client.server_capabilities.documentFormattingProvider = false
                client.server_capabilities.hoverProvider = false
                client.server_capabilities.renameProvider = false
                client.server_capabilities.definitionProvider = false
                client.server_capabilities.referencesProvider = false
                client.server_capabilities.completionProvider = false
                navic.attach(client, bufnr)
                navbuddy.attach(client, bufnr)
            end,
        })
    end,
    ["bashls"] = function()
        lspconfig.bashls.setup({
            on_attach = on_attach,
            capabilities = capabilities,
            filetypes = { "sh", "bash", "zsh" },
        })
    end,
})

if vim.fn.executable("sourcekit-lsp") == 1 then
    lspconfig.sourcekit.setup({
        on_attach = on_attach,
        capabilities = capabilities,
        root_dir = lspconfig.util.root_pattern("Package.swift", ".git"),
    })
end

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

vim.diagnostic.config({
    virtual_text = {
        prefix = "",
    },
    signs = {
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
})

-- Create a custom namespace. This will aggregate signs from all other
-- namespaces and only show the one with the highest severity on a
-- given line
local ns = vim.api.nvim_create_namespace("my_diagnostics_signs")
local orig_signs_handler = vim.diagnostic.handlers.signs

vim.diagnostic.handlers.signs = {
    show = function(_, bufnr, _, opts)
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
        local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
        orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
    end,
    hide = function(_, bufnr)
        orig_signs_handler.hide(ns, bufnr)
    end,
}
