local telescope = require("telescope")
local previewers = require("telescope.previewers")
local putils = require("telescope.previewers.utils")
local pfiletype = require("plenary.filetype")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local Path = require("plenary.path")
local pickers = require("telescope.pickers")
local utils = require("telescope.utils")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values

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

local function copy_symbol(entry)
    vim.fn.setreg("*", entry.value)
    vim.fn.setreg('"', entry.value)
    print([[Press p or "*p to paste this emoji]] .. entry.value)
end

local displayer = entry_display.create({
    separator = "│ ",
    items = {
        { width = 4 },
        { width = 40 },
        { remaining = true },
    },
})

local make_display = function(entry)
    return displayer({
        entry.value,
        entry.name,
        entry.category,
    })
end

local search_symbols = function(opts)
    local files = vim.api.nvim_get_runtime_file("data/telescope-sources/*.json", true)

    if #files == 0 then
        utils.notify("builtin.symbols", {
            msg = "No sources found! Check out https://github.com/nvim-telescope/telescope-symbols.nvim "
                .. "for some prebuild symbols or how to create you own symbol source.",
            level = "ERROR",
        })
        return
    end

    local sources = {}
    if opts.sources then
        for _, v in ipairs(files) do
            for _, s in ipairs(opts.sources) do
                if v:find(s) then
                    table.insert(sources, v)
                end
            end
        end
    else
        sources = files
    end

    local results = {}
    for _, source in ipairs(sources) do
        local data = vim.json.decode(Path:new(source):read())
        local category = vim.fn.fnamemodify(source, ":t:r")
        for _, entry in ipairs(data) do
            if #entry == 2 then
                entry[3] = category
            end
            table.insert(results, entry)
        end
    end

    pickers
        .new(opts, {
            prompt_title = "Symbols",
            finder = finders.new_table({
                results = results,
                entry_maker = function(entry)
                    return make_entry.set_default_entry_mt({
                        value = entry[1],
                        name = entry[2],
                        category = entry[3],
                        ordinal = entry[1] .. entry[2] .. entry[3],
                        display = make_display,
                    }, opts)
                end,
            }),
            sorter = conf.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr)
                actions.select_default:replace(function()
                    local symbol = action_state.get_selected_entry()
                    actions.close(prompt_bufnr)
                    copy_symbol(symbol)
                end)
                return true
            end,
        })
        :find()
end

require("telescope.builtin").symbols = search_symbols

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
        selection_caret = "󰁔 ",
        entry_prefix = "  ",
        dynamic_preview_title = true,
        buffer_previewer_maker = new_maker,
        file_ignore_patterns = {
            "^venv/",
        },
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

vim.api.nvim_create_user_command("Symbols", function()
    local files = vim.api.nvim_get_runtime_file("data/telescope-sources/*.json", true)
    if #files == 0 then
        utils.notify("builtin.symbols", {
            msg = "No sources found! Check out https://github.com/nvim-telescope/telescope-symbols.nvim "
                .. "for some prebuild symbols or how to create you own symbol source.",
            level = "ERROR",
        })
        return
    end
    local results = { "all" }
    for _, file in ipairs(files) do
        local category = vim.fn.fnamemodify(file, ":t:r")
        table.insert(results, category)
    end
    vim.ui.select(results, {
        prompt = "Symbols",
    }, function(choice)
        if choice == nil then
            return
        elseif choice == "all" then
            require("telescope.builtin").symbols({})
        else
            require("telescope.builtin").symbols({ sources = { choice } })
        end
    end)
end, {})

vim.api.nvim_create_user_command("Theme", require("telescope.builtin").colorscheme, {})

vim.keymap.set("n", "<m-j>", "<cmd>Telescope<cr>", { silent = true })
vim.keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>", { silent = true })
vim.keymap.set("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { silent = true })
vim.keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>", { silent = true })
vim.keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", { silent = true })
vim.keymap.set("n", "<leader>fs", function()
    require("auto-session").setup_session_lens()
    require("auto-session.session-lens").search_session()
end, { silent = true, desc = "Search Sessions" })
vim.keymap.set("n", "<leader>fc", "<cmd>Telescope commands<cr>", { silent = true })
vim.keymap.set("n", "<leader>ft", "<cmd>Telescope filetypes<cr>", { silent = true })
vim.keymap.set("n", "<leader>fr", "<cmd>Telescope resume<cr>", { silent = true })

vim.cmd("hi TelescopeSelectionCaret guibg=" .. require("util").get_hl("TelescopeSelection", "bg#"))
