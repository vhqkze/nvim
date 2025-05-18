local function set_python_path(path)
    local clients = vim.lsp.get_clients({
        bufnr = vim.api.nvim_get_current_buf(),
        name = "basedpyright",
    })
    for _, client in ipairs(clients) do
        if client.settings then
            client.settings.python = vim.tbl_deep_extend("force", client.settings.python or {}, { pythonPath = path })
        else
            client.config.settings = vim.tbl_deep_extend("force", client.config.settings, { python = { pythonPath = path } })
        end
        client:notify("workspace/didChangeConfiguration", { settings = nil })
    end
end

local function get_python_venv_path(root_dir)
    if vim.fn.isdirectory(root_dir .. "/venv") == 1 then
        return root_dir .. "/venv"
    elseif vim.fn.isdirectory(root_dir .. "/.venv") == 1 then
        return root_dir .. "/.venv"
    elseif vim.fn.executable("poetry") == 1 then
        local obj = vim.system({ "poetry", "env", "info", "-p" }, { cwd = root_dir, text = true }):wait()
        if obj.code == 0 then
            return vim.trim(obj.stdout)
        end
    end
end

local function reset_python_env(root_dir)
    local venv_path = get_python_venv_path(root_dir)
    if not venv_path then
        vim.notify("no python interpreter!", vim.log.levels.WARN, { title = "pyright" })
        return
    end
    if vim.env.VIRTUAL_ENV ~= nil then
        local old_venv_path = vim.env.VIRTUAL_ENV
        local new_path = {}
        for _, path in pairs(vim.split(vim.env.PATH, ":")) do
            if path ~= nil and not vim.startswith(path, old_venv_path) then
                table.insert(new_path, path)
            end
        end
        vim.env.VIRTUAL_ENV = nil
        vim.env.path = table.concat(new_path, ":")
    end
    vim.env.VIRTUAL_ENV = venv_path
    vim.env.PATH = vim.env.VIRTUAL_ENV .. "/bin:" .. vim.env.PATH
    set_python_path(venv_path .. "/bin/python")
end

return {
    cmd = { "basedpyright-langserver", "--stdio" },
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
        basedpyright = {
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
        reset_python_env(client.root_dir)
    end,
    on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "PyrightOrganizeImports", function()
            local params = { command = "basedpyright.organizeimports", arguments = { vim.uri_from_bufnr(bufnr) } }
            client:request("workspace/executeCommand", params, nil, 0)
        end, { desc = "Organize Imports" })
        vim.api.nvim_buf_create_user_command(bufnr, "PyrightSetPythonPath", set_python_path, {
            desc = "Reconfigure basedpyright with the provided python path",
            nargs = 1,
            complete = "file",
        })
        vim.keymap.set("n", "<leader>o", function()
            local params = { command = "basedpyright.organizeimports", arguments = { vim.uri_from_bufnr(bufnr) } }
            client:request("workspace/executeCommand", params, nil, 0)
        end, { silent = true, buffer = bufnr, desc = "Organize imports" })
    end,
}
