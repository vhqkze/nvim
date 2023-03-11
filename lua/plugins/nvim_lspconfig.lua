local lspconfig = require("lspconfig")
local mason_lspconfig = require("mason-lspconfig")
local navic = require("nvim-navic")
local util = require("util")

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
                navic.attach(client, bufnr)
            end,
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

local cursorline_background = util.get_hl("CursorLine", "background")

local function add_cursorline_sign_bg(name)
    local hl = util.get_hl(name)
    if hl then
        hl.background = cursorline_background
    end
    return hl
end

local signs = { Error = " ", Warn = " ", Info = " ", Hint = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    local cursor_hl = "CursorLineSign" .. type
    vim.api.nvim_set_hl(0, cursor_hl, add_cursorline_sign_bg(hl))
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "", culhl = cursor_hl })
end

vim.diagnostic.config({
    virtual_text = {
        prefix = "",
    },
    severity_sort = {
        reverse = true,
    },
})

vim.api.nvim_create_autocmd("DiagnosticChanged", {
    callback = function(args)
        local buf = args.buf
        local diagnostics = args.data.diagnostics
        local line_numbers = {}
        for _, diagnostic in ipairs(diagnostics) do
            if vim.tbl_contains(line_numbers, diagnostic.lnum + 1) then
                local line_signs = vim.fn.sign_getplaced(buf, { group = "*", lnum = diagnostic.lnum + 1 })[1].signs
                local max_severity = { priority = 999 }
                for _, sign in pairs(line_signs) do
                    if sign.name:find("Diagnostic") and sign.priority < max_severity.priority then
                        max_severity = sign
                    end
                end
                if max_severity.priority ~= 999 then
                    for _, sign in pairs(line_signs) do
                        if sign.name:find("Diagnostic") and sign.id ~= max_severity.id then
                            vim.fn.sign_unplace(sign.group, { buffer = buf, id = sign.id })
                        end
                    end
                end
            end
            table.insert(line_numbers, diagnostic.lnum + 1)
        end
    end,
})
