require("mason").setup({
    ui = {
        border = "rounded",
        icons = {
            package_installed = "󰗠",
            package_pending = "",
            package_uninstalled = "󰅙",
        },
        height = 0.8,
    },
})

local ensure_installed = {
    -- lua
    "lua-language-server",
    "stylua", -- lua formatter
    -- text
    "ltex-ls-plus",
    "marksman",
    "markdownlint",
    -- other
    "bash-language-server",
    "commitlint",
    "css-lsp",
    "html-lsp",
    "json-lsp",
    "lemminx", -- xml lsp
    "taplo", -- toml lsp
    "vim-language-server",
    "yaml-language-server",
    "prettier",
    "shfmt", -- shell formatter
    "shellcheck", -- bash linter
    "actionlint", -- github action linter
}
if vim.fn.executable("python3") == 1 then
    table.insert(ensure_installed, "python-lsp-server")
    table.insert(ensure_installed, "basedpyright")
    table.insert(ensure_installed, "yapf") -- python formatter
end
if vim.fn.executable("go") == 1 then
    table.insert(ensure_installed, "gopls") -- go lsp
end
if vim.fn.executable("java") == 1 then
    table.insert(ensure_installed, "jdtls") -- java lsp
end
if vim.fn.executable("node") == 1 then
    table.insert(ensure_installed, "eslint-lsp") -- typescript
    table.insert(ensure_installed, "typescript-language-server") -- typescript
end
if vim.fn.executable("nginx") == 1 then
    table.insert(ensure_installed, "nginx-language-server") -- nginx
end
if vim.fn.executable("gem") == 1 then
    table.insert(ensure_installed, "rubocop") -- ruby
end

if vim.env.TERMUX_VERSION then
    ensure_installed = vim.tbl_filter(function(item)
        return not vim.list_contains({
            "basedpyright",
            "lemminx",
            "lua-language-server",
        }, item)
    end, ensure_installed)
end

local function mason_install(packages)
    local registry = require("mason-registry")
    for _, package_name in pairs(packages) do
        if registry.has_package(package_name) then
            if not registry.is_installed(package_name) then
                local package = registry.get_package(package_name)
                vim.notify("Installing " .. package_name, vim.log.levels.INFO, { title = "mason.nvim" })
                package:install(
                    {},
                    vim.schedule_wrap(function(success, err)
                        if success then
                            vim.notify(package_name .. " was successfully installed.", vim.log.levels.INFO, { title = "mason.nvim" })
                        else
                            local msg = string.format("%s failed to install.\n%s", package_name, err)
                            vim.notify(msg, vim.log.levels.ERROR, { title = "mason.nvim" })
                        end
                    end)
                )
            end
        else
            vim.notify(package_name .. " does not exist.", vim.log.levels.WARN, { title = "mason.nvim" })
        end
    end
end

vim.schedule(function()
    mason_install(ensure_installed)
end)
