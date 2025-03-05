vim.keymap.set("c", "<c-up>", "<up>", { silent = true })
vim.keymap.set("c", "<c-down>", "<down>", { silent = true })

local wilder = require("wilder")
wilder.setup({
    modes = { ":", "/", "?" },
    next_key = "<Down>",
    previous_key = "<Up>",
    accept_key = "<Tab>",
    reject_key = "<Right>",
})
-- wilder: fuzzy search
wilder.set_option("pipeline", {
    wilder.branch(
        wilder.python_file_finder_pipeline({
            file_command = { "fd", "-tf" },
            dir_command = { "fd", "-td" },
            filters = { "fuzzy_filter", "difflib_sorter" },
        }),
        wilder.cmdline_pipeline({
            -- sets the language to use, 'vim' and 'python' are supported
            language = "python",
            -- 0 turns off fuzzy matching
            -- 1 turns on fuzzy matching
            -- 2 partial fuzzy matching (match does not have to begin with the same first letter)
            fuzzy = 2,
            -- set_pcre2_pattern = 1,
        }),
        wilder.python_search_pipeline({
            -- pattern = 'fuzzy',
            pattern = wilder.python_fuzzy_pattern(),
            sorter = wilder.python_difflib_sorter(),
            engine = "re",
        })
    ),
})
-- wilder: highlights
-- stylua: ignore
local gradient = {
    "#f4468f", "#fd4a85", "#ff507a", "#ff566f", "#ff5e63",
    "#ff6658", "#ff704e", "#ff7a45", "#ff843d", "#ff9036",
    "#f89b31", "#efa72f", "#e6b32e", "#dcbe30", "#d2c934",
    "#c8d43a", "#bfde43", "#b6e84e", "#aff05b",
}
for i, fg in ipairs(gradient) do
    gradient[i] = wilder.make_hl("WilderGradient" .. i, "Pmenu", { { a = 1 }, { a = 1 }, { foreground = fg } })
end
-- wilder: fzf search with highlight with border
wilder.set_option(
    "renderer",
    wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
        border = "rounded",
        highlights = {
            gradient = gradient, -- must be set
            -- selected_gradient key can be set to apply gradient highlighting for the selected candidate.
            border = "Normal",
        },
        highlighter = wilder.highlighter_with_gradient({
            wilder.basic_highlighter(), -- or wilder.lua_fzy_highlighter(),
        }),
        left = { " ", wilder.popupmenu_devicons() },
        right = { " ", wilder.popupmenu_scrollbar() },
    }))
)

-- wilder: fzf search with highlight without border
-- wilder.set_option('renderer', wilder.popupmenu_renderer({
--     highlights = {
--         gradient = gradient, -- must be set
--         -- selected_gradient key can be set to apply gradient highlighting for the selected candidate.
--     },
--     highlighter = wilder.highlighter_with_gradient({
--         wilder.basic_highlighter(), -- or wilder.lua_fzy_highlighter(),
--     }),
--     left = { ' ', wilder.popupmenu_devicons() },
--     right = { ' ', wilder.popupmenu_scrollbar() },
--     -- empty_message = 'hello',
-- }))
