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

local lsp = {
    "bashls",
    "html",
    "jsonls",
    "lemminx",
    "lua_ls",
    "marksman",
    "taplo",
    "vimls",
    "yamlls",
}
if vim.fn.executable("python") == 1 then
    table.insert(lsp, "pylsp") -- python lsp
    table.insert(lsp, "pyright") -- python lsp
end
if vim.fn.executable("go") == 1 then
    table.insert(lsp, "gopls") -- go lsp
end
if vim.fn.executable("java") == 1 then
    table.insert(lsp, "jdtls") -- java lsp
end
if vim.fn.executable("languagetool") == 1 then
    table.insert(lsp, "ltex") -- languagetool
end
if vim.fn.executable("node") == 1 then
    table.insert(lsp, "eslint") -- typescript
end
if vim.fn.executable("nix") == 1 then
    table.insert(lsp, "rnix") -- nix
end
if vim.fn.executable("nginx") == 1 then
    table.insert(lsp, "nginx-language-server") -- nginx
end

require("mason-lspconfig").setup({
    ensure_installed = lsp,
})

local need_install = {
    "markdownlint",
    "prettier",
    "stylua",
    "yapf",
    "shfmt",
    "shellcheck",
}

local function mason_install_all_need_tools(packages)
    local registry = require("mason-registry")
    for _, package_name in pairs(packages) do
        if registry.has_package(package_name) then
            local package = registry.get_package(package_name)
            if not package:is_installed() then
                package:install()
            end
        else
            print("package is not exist:", package_name)
        end
    end
end

mason_install_all_need_tools(need_install)
