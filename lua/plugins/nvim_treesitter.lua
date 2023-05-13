for _, config in pairs(require("nvim-treesitter.parsers").get_parser_configs()) do
    config.install_info.url = config.install_info.url:gsub("https://github.com/", "https://ghproxy.com/https://github.com/")
end

require("nvim-treesitter.configs").setup({
    ensure_installed = {
        "bash",
        "comment",
        "css",
        "dockerfile",
        "gitignore",
        "go",
        "gomod",
        "html",
        "http",
        "java",
        "javascript",
        "json",
        "json5",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "norg",
        "python",
        "regex",
        "sql",
        "swift",
        "toml",
        "vim",
        "yaml",
    },
    highlight = {
        enable = true,
        sync_install = false,
        additional_vim_regex_highlighting = false,
        disable = { "markdown" },
    },
    indent = {
        enable = false,
    },
    rainbow = {
        enable = true,
        extended_mode = true,
        max_file_lines = nil,
    },
})
