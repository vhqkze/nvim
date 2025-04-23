return {
    cmd = { "yaml-language-server", "--stdio" },
    filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab" },
    root_markers = { ".git" },
    settings = {
        yaml = {
            format = {
                enable = true,
                bracketSpacing = false,
            },
            hover = true,
            completion = true,
            schemaStore = {
                enable = true,
            },
            editor = {
                formatOnType = true,
            },
            keyOrdering = false,
        },
        redhat = { telemetry = { enabled = false } },
    },
}
