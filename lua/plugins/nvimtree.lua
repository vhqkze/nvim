local api = require("nvim-tree.api")

local function on_attach(bufnr)
    api.map.on_attach.default(bufnr)

    vim.keymap.set("n", "<space>", function()
        if vim.fn.executable("qlmanage") == 0 then
            return
        end
        local file = api.tree.get_node_under_cursor().absolute_path
        vim.system({ "qlmanage", "-p", file })
    end, { buf = bufnr, nowait = true, desc = "quick look" })
end

require("nvim-tree").setup({
    on_attach = on_attach,
    view = {
        width = {
            min = 25,
            max = 50,
        },
    },
    sync_root_with_cwd = true,
    filters = {
        custom = {
            "\\.DS_Store",
            "__pycache__",
        },
    },
    renderer = {
        group_empty = true,
        icons = {
            web_devicons = {
                folder = {
                    enable = false,
                },
            },
            git_placement = "signcolumn",
            symlink_arrow = " -> ",
            glyphs = {
                default = "",
                folder = {
                    arrow_closed = "",
                    arrow_open = "",
                },
                -- stylua: ignore
                git = {
                    unstaged  = "",
                    staged    = "",
                    unmerged  = "",
                    renamed   = "",
                    untracked = "",
                    deleted   = "",
                    ignored   = "",
                },
            },
        },
    },
    git = {
        show_on_dirs = true,
        show_on_open_dirs = false,
    },
    actions = {
        open_file = {
            quit_on_open = true,
        },
        change_dir = {
            enable = true,
            global = true,
        },
        file_popup = {
            open_win_config = {
                border = "rounded",
            },
        },
    },
    update_focused_file = {
        enable = true,
    },
})

vim.keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<cr>", { silent = true })
vim.keymap.set("n", "<leader>tf", "<cmd>NvimTreeFindFile<cr>", { silent = true })
vim.keymap.set("n", "<leader>to", "<cmd>NvimTreeOpen<cr>", { silent = true })
