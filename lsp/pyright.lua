local function set_python_path(path)
    local clients = vim.lsp.get_clients({
        bufnr = vim.api.nvim_get_current_buf(),
        name = "pyright",
    })
    for _, client in ipairs(clients) do
        if client.settings then
            client.settings.python = vim.tbl_deep_extend("force", client.settings.python, { pythonPath = path })
        else
            client.config.settings = vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
        end
        client:notify("workspace/didChangeConfiguration", { settings = nil })
    end
end

return {
    cmd = { "pyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        "pyrightconfig.json",
        ".git",
    },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
            },
        },
    },
    on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.hoverProvider = false
        client.server_capabilities.renameProvider = false
        client.server_capabilities.definitionProvider = false
        client.server_capabilities.referencesProvider = false
        client.server_capabilities.completionProvider = false
        client.server_capabilities.signatureHelpProvider = false
    end,
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "PyrightOrganizeImports", function()
            local params = { command = "pyright.organizeimports", arguments = { vim.uri_from_bufnr(bufnr) } }
            client:request("workspace/executeCommand", params, nil, 0)
        end, { desc = "Organize Imports" })
        vim.api.nvim_buf_create_user_command(bufnr, "PyrightSetPythonPath", set_python_path, {
            desc = "Reconfigure pyright with the provided python path",
            nargs = 1,
            complete = "file",
        })
        vim.keymap.set("n", "<leader>o", function()
            local params = { command = "pyright.organizeimports", arguments = { vim.uri_from_bufnr(bufnr) } }
            client:request("workspace/executeCommand", params, nil, 0)
        end, { silent = true, buffer = bufnr, desc = "Organize imports" })
    end,
}
