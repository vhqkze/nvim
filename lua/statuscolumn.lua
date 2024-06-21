local util = require("util")
local ffi = require("ffi")

ffi.cdef([[
	int next_namespace_id;
	uint64_t display_tick;
	typedef struct {} Error;
	typedef struct {} win_T;
	typedef struct {
		int start;  // line number where deepest fold starts
		int level;  // fold level, when zero other fields are N/A
		int llevel; // lowest level that starts in v:lnum
		int lines;  // number of lines from v:lnum to end of closed fold
	} foldinfo_T;
	foldinfo_T fold_info(win_T* wp, int lnum);
	win_T *find_window_by_handle(int Window, Error *err);
	int compute_foldcolumn(win_T *wp, int col);
	int win_col_off(win_T *wp);
]])

local cursorline_background = util.get_hl("CursorLine", "bg#")

local function add_cursorline_sign_bg(texthl)
    local new_hl_name = "CursorLine" .. texthl
    local hl = vim.api.nvim_get_hl(0, { name = texthl, link = true })
    if hl then
        hl.background = cursorline_background
        vim.api.nvim_set_hl(0, new_hl_name, hl)
    end
    return new_hl_name
end

------ sign --------

local function get_signs()
    local buf = vim.api.nvim_win_get_buf(0)
    local result = vim.tbl_map(function(sign)
        local details = vim.fn.sign_getdefined(sign.name)
        if vim.tbl_isempty(details) then
            return {}
        end
        local detail = details[1]
        detail.priority = sign.priority
        detail.lnum = sign.lnum
        return detail
    end, vim.fn.sign_getplaced(buf, { group = "*", lnum = vim.v.lnum })[1].signs)
    return result
end

function GetSignCol(name)
    local signs = get_signs()
    if vim.tbl_isempty(signs) then
        return ""
    end
    local sign = nil
    if name == nil then
        for _, s in ipairs(signs) do
            if s.name ~= nil and not s.name:find("GitSigns") and not s.name:find("Diagnostic") then
                sign = s
                break
            end
        end
    elseif name == "Diagnostic" then
        if vim.v.relnum == 0 then
            vim.notify("signs: " .. vim.v.lnum .. vim.inspect(signs))
        end
        local diagnostics = { "DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint" }
        local found_diagnostic = false
        for _, diagnostic_level in ipairs(diagnostics) do
            for _, s in ipairs(signs) do
                if s.name ~= nil and s.name:find(diagnostic_level) then
                    sign = s
                    found_diagnostic = true
                    break
                end
            end
            if found_diagnostic then
                break
            end
        end
    else
        for _, s in ipairs(signs) do
            if s.name ~= nil and s.name:find(name) then
                sign = s
                break
            end
        end
    end
    if sign == nil then
        return ""
    end
    local sign_hl = sign.texthl
    if vim.v.relnum == 0 then
        sign_hl = add_cursorline_sign_bg(sign.texthl)
    end
    return "%#" .. sign_hl .. "#" .. sign.text .. "%*"
end

------ fold --------

function FoldSymbol()
    local winid = vim.api.nvim_get_current_win()
    local culopt = vim.api.nvim_get_option_value("cursorlineopt", { win = winid })
    local fillchars = vim.opt.fillchars:get()
    local result = ""
    local width = 3
    local args = {
        wp = ffi.C.find_window_by_handle(winid, ffi.new("Error")),
        lnum = vim.v.lnum,
        relnum = vim.v.relnum,
        cul = vim.api.nvim_get_option_value("cursorline", { win = winid }) and (culopt:find("number") or culopt:find("both")),
    }
    local foldinfo = ffi.C.fold_info(args.wp, args.lnum)
    local level = foldinfo.level
    local closed = foldinfo.lines > 0
    if level == 0 then
        return "    "
    elseif closed then
        return " " .. fillchars["foldclose"] .. "  "
    elseif foldinfo.start == args.lnum then
        return " " .. fillchars["foldopen"] .. "  "
    else
        return " " .. fillchars["foldsep"] .. "  "
    end
end

function FoldClick(minwid, clicks, button, mods)
    local winid = vim.fn.getmousepos().winid
    vim.api.nvim_set_current_win(winid)
    local line = vim.fn.getmousepos().line
    local wp = ffi.C.find_window_by_handle(winid, ffi.new("Error"))
    local foldinfo = ffi.C.fold_info(wp, line)
    local closed = foldinfo.lines > 0
    vim.schedule(function()
        if closed then
            vim.cmd(line .. "foldopen")
        elseif foldinfo.start == line then
            vim.cmd(line .. "foldclose")
        end
    end)
end

------------------- runner ---------------------

vim.api.nvim_set_hl(0, "Runner1", { fg = "#c4e791" })
vim.api.nvim_set_hl(0, "Runner2", { fg = "#eed49f" })
vim.api.nvim_set_hl(0, "CursorLineRunner1", { fg = "#c4e791", bg = cursorline_background })
vim.api.nvim_set_hl(0, "CursorLineRunner2", { fg = "#eed49f", bg = cursorline_background })

-- pytest
function PytestSymbol()
    local content = vim.fn.getline(vim.v.lnum)
    if string.match(content, "^%s*def%s+test_") then --function
        return "%#" .. (vim.v.relnum == 0 and "CursorLineRunner1" or "Runner1") .. "# %*"
    elseif string.match(content, "^%s*class%s+Test[^_]") then --class
        return "%#" .. (vim.v.relnum == 0 and "CursorLineRunner2" or "Runner2") .. "# %*"
    else
        return "   "
    end
end

function PytestClick(minwid, clicks, button, mods)
    local winid = vim.fn.getmousepos().winid
    vim.api.nvim_set_current_win(winid)
    local line = vim.fn.getmousepos().line
    vim.api.nvim_win_set_cursor(0, { line, 0 })
    local content = vim.fn.getline(line)
    if string.match(content, "^%s*def%s+test_") then
        vim.schedule(require("pytest").run_function)
    elseif string.match(content, "^%s*class%s+Test[^_]") then
        vim.schedule(require("pytest").run_class)
    end
end

------------------ config --------------------

--- 指定buftype、filetype对应的内容
--value可以为string或者table
--为string类型时，signcolumn=no, foldcolumn=0, nonumber
--为table类型时, 可指定各项值
--找不到对应的filetype时，检查buftype，为空则statuscolumn=nil
--否则使用["*"] 中定义的值
local my_opts = {
    [""] = {
        startify = "",
        dashboard = "",
        toggleterm = "",
        python = {
            statuscolumn = {
                "%s",
                "%=",
                "%l",
                "%@v:lua.PytestClick@%{%v:lua.PytestSymbol()%}%X",
                "%@v:lua.FoldClick@%{v:lua.FoldSymbol()}%X",
            },
            signcolumn = "yes:2",
            number = true,
        },
        ["*"] = {
            statuscolumn = {
                "%s", -- sign
                -- "%{%v:lua.GetSignCol('GitSigns')%}",
                -- "%{%v:lua.GetSignCol('Diagnostic')%}",
                -- "%{%v:lua.GetSignCol()%}",
                "%=",
                "%l", --number
                "%@v:lua.FoldClick@%{v:lua.FoldSymbol()}%X",
            },
            signcolumn = "yes:2",
            number = true,
        },
    },
    help = {
        ["*"] = {
            statuscolumn = "   ",
        },
    },
    nofile = {
        NvimTree = {
            statuscolumn = "%s",
            signcolumn = "yes",
        },
        man = "",
        spectre_panel = {
            statuscolumn = " %l%@v:lua.FoldClick@%{v:lua.FoldSymbol()}%X",
            number = true,
        },
        ["*"] = "",
    },
    nowrite = {
        ["*"] = "",
    },
    terminal = {
        ["*"] = "",
    },
    ["*"] = {
        ["*"] = "",
    },
}

local function get_opts(buftype, filetype)
    if vim.fn.has_key(my_opts, buftype) == 0 then
        buftype = "*"
    end
    if vim.fn.has_key(my_opts[buftype], filetype) == 0 then
        filetype = "*"
    end
    ---@type nil|string|table
    local opt = my_opts[buftype][filetype]
    local default_opts = {
        statuscolumn = "",
        signcolumn = "no",
        foldcolumn = "0",
        number = false,
        numberwidth = 1,
    }
    if type(opt) == "string" then
        default_opts.statuscolumn = opt
    elseif type(opt) == "table" then
        default_opts = vim.tbl_deep_extend("force", default_opts, opt)
        if type(opt.statuscolumn) == "table" then
            default_opts.statuscolumn = table.concat(opt.statuscolumn)
        end
    end
    return default_opts
end

vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    pattern = "*",
    callback = function(args)
        local filetype = vim.bo[args.buf].filetype
        local buftype = vim.bo[args.buf].buftype
        local opt = get_opts(buftype, filetype)
        for key, value in pairs(opt) do
            vim.opt_local[key] = value
        end
    end,
})

vim.defer_fn(function()
    vim.cmd(string.format("hi CursorLineNr guibg=%s", cursorline_background))
    vim.cmd(string.format("hi CursorLineFold guibg=%s", cursorline_background))
    vim.cmd(string.format("hi CursorLineSign guibg=%s", cursorline_background))
    local all_signs = vim.fn.sign_getdefined()
    for _, sign in ipairs(all_signs) do
        sign.culhl = "CursorLine" .. sign.name
        local texthl_name = sign.texthl
        if texthl_name ~= nil then
            local texthl = vim.api.nvim_get_hl(0, { name = sign.texthl, link = true })
            if texthl ~= nil then
                texthl.background = cursorline_background
                vim.api.nvim_set_hl(0, sign.culhl, texthl)
                vim.fn.sign_define(sign.name, { texthl = sign.texthl, text = sign.text, numhl = sign.numhl or "", culhl = sign.culhl })
            end
        end
    end
end, 3000)

vim.keymap.set("n", "<leader>in", function()
    local result = ""
    result = result .. "buftype:" .. vim.bo.buftype .. "\n"
    result = result .. "filetype:" .. vim.bo.filetype .. "\n"
    result = result .. "signcolumn:" .. vim.inspect(vim.opt_local.signcolumn:get()) .. "\n"
    result = result .. "foldcolumn:" .. vim.inspect(vim.opt_local.foldcolumn:get()) .. "\n"
    result = result .. "number:" .. vim.inspect(vim.opt_local.number:get()) .. "\n"
    result = result .. "statuscolumn:" .. vim.inspect(vim.opt_local.statuscolumn:get())
    vim.notify(result, vim.log.levels.INFO, { title = "statuscolumn" })
end, { silent = true })
