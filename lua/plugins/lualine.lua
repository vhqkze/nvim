local mode_map = {
    ["n"]      = "NORMAL",
    ["no"]     = "O-PENDING",
    ["nov"]    = "O-PENDING",
    ["noV"]    = "O-PENDING",
    -- ['no�'] = 'O-PENDING',
    ["no\22"]  = "O-PENDING",
    ["niI"]    = "NORMAL",
    ["niR"]    = "NORMAL",
    ["niV"]    = "NORMAL",
    ["nt"]     = "NORMAL",
    ["v"]      = "VISUAL",
    ["vs"]     = "VISUAL",
    ["V"]      = "V-LINE",
    ["Vs"]     = "V-LINE",
    -- ['�']   = 'V-BLOCK',
    ["\22"]    = "V-BLOCK",
    -- ['�s']  = 'V-BLOCK',
    ["\22s"]   = "V-BLOCK",
    ["s"]      = "SELECT",
    ["S"]      = "S-LINE",
    -- ['�']   = 'S-BLOCK',
    ["\19"]    = "S-BLOCK",
    ["i"]      = "INSERT",
    ["ic"]     = "INSERT",
    ["ix"]     = "INSERT",
    ["R"]      = "REPLACE",
    ["Rc"]     = "REPLACE",
    ["Rx"]     = "REPLACE",
    ["Rv"]     = "V-REPLACE",
    ["Rvc"]    = "V-REPLACE",
    ["Rvx"]    = "V-REPLACE",
    ["c"]      = "COMMAND",
    ["cv"]     = "EX",
    ["ce"]     = "EX",
    ["r"]      = "REPLACE",
    ["rm"]     = "MORE",
    ["r?"]     = "CONFIRM",
    ["!"]      = "SHELL",
    ["t"]      = "TERMINAL",
}

local function tab_or_spc()
    local sep = "Tab Size"
    if vim.bo.expandtab then
        sep = "Spaces"
    end
    return sep .. ":" .. vim.bo.shiftwidth
end
require("lualine").setup({
    options = {
        theme = "auto",
        section_separators = { left = "", right = "" },
        component_separators = "",
        disabled_filetypes = {
            statusline = {},
            winbar = {},
        },
        globalstatus = true,
    },
    sections = {
        lualine_a = {
            {
                function()
                    return mode_map[vim.api.nvim_get_mode().mode] or "??????"
                end,
            },
        },
        lualine_b = { "branch", "diff" },
        lualine_c = {
            {
                function()
                    local term_id, term = require("toggleterm.terminal").identify()
                    local name = term.display_name and term.display_name or term.name
                    if term_id == 88 then
                        return name
                    elseif term_id then
                        return term_id .. ": " .. name
                    else
                        return ""
                    end
                end,
                on_click = function()
                    vim.cmd("ToggleTerm")
                end,
            },
        },
        lualine_x = {
            {
                function()
                    local starts = vim.fn.line("v")
                    local ends = vim.fn.line(".")
                    local line_count = starts <= ends and ends - starts + 1 or starts - ends + 1
                    local chars = vim.fn.wordcount().visual_chars
                    return line_count .. " L, " .. chars .. " C selected"
                end,
                cond = function()
                    return vim.fn.mode():find("[Vv]") ~= nil
                end,
            },
            {
                function()
                    local res = vim.fn.searchcount({ maxcount = 10000, timeout = 500 })
                    if res.total > 0 then
                        return string.format("[%s/%d] %s", res.current, res.total, vim.fn.getreg("/"))
                    else
                        return ""
                    end
                end,
                cond = function()
                    return vim.api.nvim_get_vvar("hlsearch") ~= 0
                end,
            },
            {
                function()
                    return vim.tbl_isempty(require("notify").history()) and " " or " "
                end,
                on_click = function()
                    require("telescope").extensions.notify.notify()
                end,
            },
            {
                tab_or_spc,
            },
            {
                "encoding",
            },
            {
                "fileformat",
                symbols = {
                    unix = "", -- e712
                    dos = "", -- e70f
                    mac = "", -- e711
                },
                color = { fg = "#77c2d2" },
            },
            {
                "filetype",
                icons_enabled = false,
                on_click = function()
                    vim.defer_fn(function()
                        require("telescope.builtin").filetypes()
                    end, 100)
                end,
            },
        },
        lualine_y = { { "progress" } },
        lualine_z = { { "location" } },
    },
    winbar = {},
    inactive_winbar = {},
})

require("lualine").hide({
    place = { "tabline", "winbar" },
    unhide = false,
})
