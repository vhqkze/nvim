return {
    cmd = { "pylsp" },
    filetypes = { "python" },
    root_markers = {
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".git",
    },
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = {
                    enabled = false,
                },
            },
        },
    },
    on_init = function(client)
        client.server_capabilities.documentSymbolProvider = false
        client.server_capabilities.foldingRangeProvider = false
    end,
}
