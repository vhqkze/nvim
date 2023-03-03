local telescope = require("telescope")
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")
local pfiletype = require("plenary.filetype")

local new_maker = function(filepath, bufnr, opts)
    opts = opts or {}
    if opts.use_ft_detect == nil then
        local ft = pfiletype.detect(filepath)
        if ft == "lua" then
            opts.use_ft_detect = false
            putils.regex_highlighter(bufnr, ft)
        end
    end
    previewers.buffer_previewer_maker(filepath, bufnr, opts)
end

telescope.setup({
    defaults = {
        layout_config = {
            horizontal = {
                prompt_position = "top",
            },
        },
        sorting_strategy = "ascending",
        mappings = {
            i = {
                ["<esc>"] = require("telescope.actions").close,
                ["<C-Down>"] = require("telescope.actions").cycle_history_next,
                ["<C-Up>"] = require("telescope.actions").cycle_history_prev,
            },
        },
        prompt_prefix = " ",
        dynamic_preview_title = true,
        buffer_previewer_maker = new_maker,
    },
    pickers = {
        colorscheme = {
            enable_preview = true,
        },
        help_tags = {
            mappings = {
                i = {
                    ["<cr>"] = require("telescope.actions").select_vertical,
                },
            },
        },
    },
})

telescope.load_extension("session-lens")
vim.api.nvim_create_user_command("Theme", require("telescope.builtin").colorscheme, {})

vim.keymap.set("n", "<m-j>", "<cmd>Telescope<cr>", { silent = true })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { silent = true })
vim.keymap.set("n", "<leader>fs", "<cmd>Telescope session-lens search_session<cr>", { silent = true })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope commands<cr>", { silent = true })
vim.keymap.set("n", "<leader>ft", "<cmd>Telescope filetypes<cr>", { silent = true })
