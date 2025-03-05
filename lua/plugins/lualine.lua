-- stylua: ignore
local mode_map = {
    ["n"]      = "NORMAL",
    ["no"]     = "O-PENDING",
    ["nov"]    = "O-PENDING",
    ["noV"]    = "O-PENDING",
    ["no\22"]  = "O-PENDING",
    ["niI"]    = "NORMAL",
    ["niR"]    = "NORMAL",
    ["niV"]    = "NORMAL",
    ["nt"]     = "NORMAL",
    ["ntT"]    = "NORMAL",
    ["v"]      = "VISUAL",
    ["vs"]     = "VISUAL",
    ["V"]      = "V-LINE",
    ["Vs"]     = "V-LINE",
    ["\22"]    = "V-BLOCK",
    ["\22s"]   = "V-BLOCK",
    ["s"]      = "SELECT",
    ["S"]      = "S-LINE",
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
                    local name = term.display_name or term.name
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
                    if vim.g.notify_last_read == nil then
                        return vim.tbl_isempty(require("notify").history()) and " " or " "
                    else
                        for _, item in pairs(require("notify").history()) do
                            if item.time > vim.g.notify_last_read then
                                return " "
                            end
                        end
                        return " "
                    end
                end,
                on_click = function()
                    require("telescope").extensions.notify.notify()
                    vim.g.notify_last_read = vim.fn.localtime()
                end,
            },
            {
                function()
                    local sep = "Tab Size"
                    if vim.bo.expandtab then
                        sep = "Spaces"
                    end
                    return sep .. ":" .. vim.bo.shiftwidth
                end,
                on_click = function()
                    local selection = {
                        "Indent Using Spaces",
                        "Indent Using Tabs",
                        "Change Tab Display Size",
                        "Convert Indentation to Spaces",
                        "Convert Indentation to Tabs",
                    }
                    vim.ui.select(selection, {
                        prompt = "Select",
                    }, function(choice)
                        if choice == selection[1] then
                            vim.bo.expandtab = true
                        elseif choice == selection[2] then
                            vim.bo.expandtab = false
                        elseif choice == selection[3] then
                            vim.ui.input({ prompt = "Size:" }, function(input)
                                if input ~= nil and input ~= "" then
                                    local width = tonumber(input)
                                    if width == nil then
                                        print("invalid input, expecting number")
                                        return
                                    end
                                    vim.bo.tabstop = width -- 设置tab字符显示宽度
                                    vim.bo.softtabstop = width -- tab转为多少个空格
                                    vim.bo.shiftwidth = width -- 自动缩进时，缩进长度为4
                                end
                            end)
                        elseif choice == selection[4] then
                            vim.bo.expandtab = true
                            vim.cmd("retab!")
                        elseif choice == selection[5] then
                            vim.bo.expandtab = false
                            vim.cmd("retab!")
                        end
                    end)
                end,
            },
            {
                "encoding",
                on_click = function()
                    local selection = { "Reopen with Encoding", "Save with Encoding" }
                    vim.ui.select(selection, {
                        prompt = "Select",
                    }, function(choice)
                        if choice == selection[1] then
                            vim.ui.input({ prompt = choice }, function(input)
                                if input ~= nil and input ~= "" then
                                    vim.cmd("e ++enc=" .. input)
                                end
                            end)
                        elseif choice == selection[2] then
                            vim.ui.input({ prompt = choice }, function(input)
                                if input ~= nil and input ~= "" then
                                    vim.cmd("w ++enc=" .. input)
                                    vim.cmd("e")
                                end
                            end)
                        end
                    end)
                end,
            },
            {
                "fileformat",
                symbols = {
                    unix = "", -- e712
                    dos = "", -- e70f
                    mac = "", -- e711
                },
                color = { fg = "#77c2d2" },
                on_click = function()
                    vim.ui.select({ "unix", "dos", "mac" }, {
                        prompt = "Set fileformat",
                    }, function(choice)
                        if choice ~= nil then
                            vim.opt.fileformat = choice
                        end
                    end)
                end,
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
