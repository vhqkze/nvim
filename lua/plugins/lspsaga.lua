require("lspsaga").setup({
    scroll_preview = {
        scroll_up = "<c-u>",
        scroll_down = "<c-d>",
    },
    finder = {
        default = "def+ref+imp",
        keys = {
            quit = { "q", "<esc>", "<c-c>" },
        },
    },
    code_action = {
        show_server_name = true,
        keys = {
            quit = { "q", "<esc>", "<c-c>" },
        },
    },
    definition = {
        keys = {
            quit = "q",
            edit = "<C-c>o",
            vsplit = "<C-c>v",
            split = "<C-c>i",
            tabe = "<C-c>t",
            close = "<C-c>k",
        },
    },
    diagnostic = {},
    implement = {
        enable = false,
    },
    lightbulb = {
        sign_priority = 5,
        virtual_text = false,
    },
    rename = {
        keys = {
            quit = "<c-c>",
        },
    },
    symbol_in_winbar = {
        enable = false,
        separator = "  ",
    },
    ui = {
        border = "rounded",
        code_action = "💡",
        diagnostic = "🐞",
        expand = "",
        collapse = "",
    },
})

-- show hover doc and press twice will jumpto hover window
-- see nvim_ufo.lua
-- vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<cr>", { silent = true })

-- lsp finder to find the cursor word definition and reference
vim.keymap.set("n", "gh", "<cmd>Lspsaga finder<cr>", { silent = true, desc = "Find definition and reference" })

-- code action
vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<cr>", { silent = true, desc = "Code Action" })
vim.keymap.set("v", "<leader>ca", "<cmd>Lspsaga range_code_action<cr>", { silent = true, desc = "Code Action" })

-- rename
vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<cr>", { silent = true, desc = "Rename" })

-- Peek Definition
-- you can edit the definition file in this flaotwindow
-- also support open/vsplit/etc operation check definition_action_keys
-- support tagstack C-t jump back
vim.keymap.set("n", "<leader>gd", "<cmd>Lspsaga peek_definition<CR>", { silent = true })

-- diagnostic
vim.keymap.set("n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<cr>", { silent = true, desc = "Show line diagnostics" })

-- jump diagnostic, can use `<c-o>` to jump back
vim.keymap.set("n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<cr>", { silent = true, desc = "Previous diagnostic" })
vim.keymap.set("n", "]e", "<cmd>Lspsaga diagnostic_jump_next<cr>", { silent = true, desc = "Next disgnostic" })
-- or jump to error
vim.keymap.set("n", "[E", function()
    require("lspsaga.diagnostic"):goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true, desc = "Previous error" })
vim.keymap.set("n", "]E", function()
    require("lspsaga.diagnostic"):goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { silent = true, desc = "Next error" })
