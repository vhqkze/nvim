require("spectre").setup({
    highlight = {
        search = "SpectreSearch",
        replace = "SpectreReplace",
    },
    find_engine = {
        ["rg"] = {
            cmd = "rg",
            args = {
                "--color=never",
                "--no-heading",
                "--with-filename",
                "--line-number",
                "--column",
            },
            options = {
                ["ignore-case"] = {
                    value = "--ignore-case",
                    icon = "[ignore case]",
                    desc = "ignore case",
                },
                ["no-ignore"] = {
                    value = "--no-ignore",
                    icon = "[no ignore]",
                    desc = "no ignore",
                },
                ["hidden"] = {
                    value = "--hidden",
                    icon = "[hidden]",
                    desc = "hidden file",
                },
            },
        },
    },
    default = {
        find = {
            cmd = "rg",
            options = { "ignore-case" },
        },
        replace = {
            cmd = "oxi",
        },
    },
    mapping = {
        ["toggle_line"] = {
            map = "<space>",
            cmd = "<cmd>lua require('spectre').toggle_line()<CR>",
            desc = "toggle item",
        },
        ["enter_file"] = {
            map = "o",
            cmd = "<cmd>lua require('spectre.actions').select_entry()<CR>",
            desc = "open file",
        },
        ["run_current_replace"] = {
            map = "<cr>",
            cmd = "<cmd>lua require('spectre.actions').run_current_replace()<CR>",
            desc = "replace current line",
        },
        ["delete_line"] = {
            map = "<leader>rd",
            cmd = "<cmd>lua require('spectre.actions').run_delete_line()<CR>",
            desc = "delete all",
        },
    },
    is_insert_mode = true,
    is_block_ui_break = true,
})

vim.api.nvim_set_hl(0, "SpectreSearch", { bg = "#ff9e64", fg = "#1d202f" })
vim.api.nvim_set_hl(0, "SpectreReplace", { bg = "#9ece6a", fg = "#1d202f" })
