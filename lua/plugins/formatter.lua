local util = require("formatter.util")
local function prettier()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == "" then
        local tmp_path = vim.fn.tempname()
        local filetype = vim.bo.filetype
        local parser = ({
            jsonc = "json",
            javascriptreact = "javascript",
            typescriptreact = "typescript",
        })[filetype] or filetype
        local stdin = vim.fn.getbufline(vim.fn.bufnr("%"), 1, "$")
        vim.fn.writefile(stdin, tmp_path)
        local prettierrc_path = vim.fn.findfile(".prettierrc", ".;")
        if prettierrc_path == "" then
            prettierrc_path = "~/.prettierrc"
        end
        return {
            exe = "prettier",
            args = { "--config", prettierrc_path, "--parser", parser, tmp_path },
            stdin = true,
        }
    end
    return {
        exe = "prettier",
        args = { "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
        stdin = true,
    }
end

require("formatter").setup({
    logging = false,
    log_level = vim.log.levels.INFO,
    filetype = {
        lua = {
            function()
                local bufname = vim.api.nvim_buf_get_name(0)
                if bufname == "" then
                    return {
                        exe = "stylua",
                        args = { "-s", "-" },
                        stdin = true,
                    }
                end
                return {
                    exe = "stylua",
                    args = {
                        "--search-parent-directories",
                        "--stdin-filepath",
                        util.escape_path(util.get_current_buffer_file_path()),
                        "--",
                        "-",
                    },
                    stdin = true,
                }
            end,
        },
        typescript = { prettier },
        typescriptreact = { prettier },
        javascript = { prettier },
        javascriptreact = { prettier },
        css = { prettier },
        scss = { prettier },
        html = { prettier },
        yaml = { prettier },
        json = { prettier },
        json5 = { prettier },
        jsonc = { prettier },
        java = {
            function()
                vim.lsp.buf.format()
            end,
        },
        graphql = { prettier },
        markdown = {
            function()
                return {
                    exe = "markdownlint",
                    args = {
                        "-f",
                        "--disable MD041", -- disable first line must be title
                        "--disable MD013", -- disable line length > 80
                        "--",
                    },
                    stdin = false,
                }
            end,
        },
        python = require("formatter.filetypes.python").yapf,
        go = require("formatter.filetypes.go").gofmt,

        ["*"] = {
            function()
                if vim.fn.has("mac") == 1 then
                    return { exe = "sed", args = { "-i", "''", "'s/[ \t]*$//'" } }
                else
                    return require("formatter.filetypes.any").remove_trailing_whitespace()
                end
            end,
        },
    },
})

vim.keymap.set({ "n", "x" }, "<leader>fm", "<cmd>Format<cr>", { noremap = true, silent = true, desc = "Format" })
