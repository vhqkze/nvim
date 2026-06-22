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

local sections = {
    mode = {
        function()
            return mode_map[vim.api.nvim_get_mode().mode] or "??????"
        end,
    },
    inspect = {
        function()
            local buf = vim.api.nvim_get_current_buf()
            local win = vim.api.nvim_get_current_win()
            local pos = vim.fn.getcharpos(".")
            local line = vim.api.nvim_get_current_line()
            local char = vim.fn.slice(line, pos[3] - 1, pos[3])
            local unicode = ""
            if char == "\0" then
                char = "^@"
                unicode = "U+0000"
            else
                local char_count = vim.fn.strchars(char)
                for i = 1, char_count do
                    local u = vim.fn.strcharpart(char, i - 1, 1)
                    unicode = unicode .. (unicode == "" and "" or ",")
                    local n = vim.fn.char2nr(u)
                    unicode = unicode .. string.format("U+%04x", n):upper()
                end
            end
            if char == "%" then
                char = "%%"
            end
            local bytepos = vim.fn.getpos(".")
            return string.format("buf: %s, win: %s, <%s> %s, col: %s", buf, win, char, unicode, bytepos[3])
        end,
    },
    selected = {
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
    searchcount = {
        function()
            ---@type {current: number, exact_match: number, incomplete: number, maxcount: number, total: number}
            local res = vim.fn.searchcount({ maxcount = 0, timeout = 1000 })
            local content = vim.fn.getreg("/")
            if content:len() > 50 then
                content = content:sub(1, 47) .. "..."
            end
            if res.incomplete == 0 then
                if res.total > 0 then
                    return string.format("%s [%d/%d]", content, res.current, res.total)
                else
                    return ""
                end
            elseif res.incomplete == 1 then
                return string.format("%s [?/??]", content)
            elseif res.incomplete == 2 then
                if res.total > res.maxcount and res.current > res.maxcount then
                    return string.format("%s [>%d/>%d]", content, res.current - 1, res.maxcount)
                elseif res.total > res.maxcount then
                    return string.format("%s [%d/>%d]", content, res.current, res.maxcount)
                end
            end
        end,
        cond = function()
            return vim.api.nvim_get_vvar("hlsearch") == 1
        end,
    },
    notify = {
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
    indent = {
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
                    vim.cmd("retab! -indentonly")
                elseif choice == selection[5] then
                    vim.bo.expandtab = false
                    vim.cmd("retab! -indentonly")
                end
            end)
        end,
    },
    encoding = {
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
    fileformat = {
        "fileformat",
        symbols = {
            unix = "", -- e712
            dos = "", -- e70f
            mac = "", -- e711
        },
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
    filetype = {
        "filetype",
        icons_enabled = false,
        on_click = function()
            vim.defer_fn(function()
                require("telescope.builtin").filetypes()
            end, 100)
        end,
    },
    stat = {
        function()
            local file = require("nvim-tree.api").tree.get_node_under_cursor()
            local cmd = { "stat", "-c", "%s %A %U:%G %y", file.absolute_path }
            if vim.fn.has("mac") == 1 then
                cmd = { "stat", "-f", "%z %Sp %Su:%Sg %Sm", "-t", "%Y-%m-%d %H:%M:%S", file.absolute_path }
            end
            local obj = vim.system(cmd, { text = true }):wait()
            local result = vim.trim(obj.stdout)
                :gsub("^%d+ .", function(match)
                    local split_strings = vim.split(match, " ")
                    local size, t = split_strings[1], split_strings[2]
                    if t ~= "-" then
                        return t
                    end
                    local s = tonumber(size)
                    if s < 1024 then
                        size = s
                    elseif s < 1024 ^ 2 then
                        size = string.format("%.3f", s / 1024):gsub("%.?0+$", "") .. " KiB"
                    elseif s < 1024 ^ 3 then
                        size = string.format("%.3f", s / 1024 ^ 2):gsub("%.?0+$", "") .. " MiB"
                    else
                        size = string.format("%.3f", s / 1024 ^ 3):gsub("%.?0+$", "") .. " GiB"
                    end
                    return size .. " " .. t
                end)
                :gsub("(%d%d:%d%d:%d%d)%..*", "%1")
            return result
        end,
    },
}

local nvim_tree = {
    sections = {
        lualine_a = {
            function()
                return "NVIMTREE"
            end,
        },
        lualine_b = {
            function()
                local file = require("nvim-tree.api").tree.get_node_under_cursor()
                return file.absolute_path
            end,
        },
        lualine_x = {
            sections.selected,
            sections.searchcount,
            sections.stat,
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    filetypes = { "NvimTree" },
}

local toggleterm = {
    sections = {
        lualine_a = {
            function()
                local term_id, _ = require("toggleterm.terminal").identify()
                return "ToggleTerm #" .. tostring(term_id)
            end,
        },
        lualine_b = {
            function()
                local _, term = require("toggleterm.terminal").identify()
                local name = term.display_name or term.name:gsub(";#toggleterm#%d+$", "")
                return name
            end,
        },
        lualine_x = {
            sections.selected,
            sections.searchcount,
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
    },
    filetypes = { "toggleterm" },
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
        lualine_a = { sections.mode },
        lualine_b = { "branch", "diff" },
        lualine_c = {},
        lualine_x = {
            sections.selected,
            sections.searchcount,
            sections.notify,
            sections.indent,
            sections.encoding,
            sections.fileformat,
            sections.filetype,
        },
        lualine_y = { { "progress" } },
        lualine_z = { { "location" } },
    },
    winbar = {},
    tabline = {},
    inactive_winbar = {},
    extensions = { nvim_tree, toggleterm },
})
