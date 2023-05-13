require("mason").setup({
    ui = {
        border = "rounded",
        icons = {
            package_installed = "",
            package_pending = "➜",
            package_uninstalled = "",
        },
        height = 0.8,
    },
})

local lsp = { "lua_ls", "html", "pylsp", "pyright", "jsonls", "bashls", "vimls", "yamlls" }
if vim.fn.executable("go") == 1 then
    table.insert(lsp, "gopls") -- go lsp
end
if vim.fn.executable("java") == 1 then
    table.insert(lsp, "jdtls") -- java lsp
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
    "lemminx", -- xml lsp
    "nginx-language-server",
}

function mason_install_all_need_tools(packages)
    local registry = require("mason-registry")
    for _, package_name in pairs(packages) do
        local package_exist = registry.has_package(package_name)
        if package_exist then
            local package = registry.get_package(package_name)
            local is_installed = package:is_installed()
            if not is_installed then
                package:install()
            end
        else
            print("package is not exist:", package_name)
        end
    end
end

vim.api.nvim_create_user_command("MasonInstallAllTools", function()
    mason_install_all_need_tools(need_install)
end, { desc = "Mason install all tools except for lsp" })
