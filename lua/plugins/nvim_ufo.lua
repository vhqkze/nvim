vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

--- 对连续的多行注释折叠
--- 单独的一行注释不会折叠
--- 中间间隔一行或多行空行的两行注释会视为一整块注释
---@param bufnr integer
---@return table
local function getCommentFolds(bufnr)
    local comment_folds = {}
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    local is_in_comment = false
    local comment_start = 0
    local comment_end = 0
    local commentstring = vim.o.commentstring
    local comment_pattern = "^%s*" .. commentstring:sub(1, 1)
    if commentstring == "" then
        return comment_folds
    end
    for i = 0, line_count - 1 do
        local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
        local is_comment_line = line:match(comment_pattern)
        if not is_in_comment and is_comment_line then
            is_in_comment = true
            comment_start = i
            comment_end = i
        elseif is_in_comment and is_comment_line then
            comment_end = i
        elseif is_in_comment and not line:match("^%s*$") and not is_comment_line then
            is_in_comment = false
            if comment_end > comment_start then
                table.insert(comment_folds, { startLine = comment_start, endLine = comment_end, kind = "comment" })
            end
        end
    end
    if is_in_comment and comment_end > comment_start then
        table.insert(comment_folds, { startLine = comment_start, endLine = comment_end, kind = "comment" })
    end
    return comment_folds
end

local function getFoldsWithCustom(bufnr, providerName)
    local folds = require("ufo").getFolds(bufnr, providerName)
    if providerName == "lsp" then
        folds = folds:thenCall(function(lsp_folds)
            if lsp_folds == nil then
                lsp_folds = {}
            end
            for _, comment_fold in pairs(getCommentFolds(bufnr)) do
                table.insert(lsp_folds, comment_fold)
            end
            return lsp_folds
        end)
    else
        for _, comment_fold in pairs(getCommentFolds(bufnr)) do
            table.insert(folds, comment_fold)
        end
    end
    return folds
end

-- lsp->treesitter->indent
local function customizeSelector(bufnr)
    local function handleFallbackException(err, providerName)
        if type(err) == "string" and err:match("UfoFallbackException") then
            return getFoldsWithCustom(bufnr, providerName)
        else
            return require("promise").reject(err)
        end
    end

    local folds = getFoldsWithCustom(bufnr, "lsp")
        :catch(function(err)
            return handleFallbackException(err, "treesitter")
        end)
        :catch(function(err)
            return handleFallbackException(err, "indent")
        end)

    return folds
end

local function addVirtText(virtText, width, truncate, isEnd)
    local newVirtText = {}
    local usedWidth = 0
    for i, chunk in ipairs(virtText) do
        local chunkText = chunk[1]
        if isEnd and i == 1 and vim.trim(chunkText) == "" then
            goto continue
        end
        local chunkWidth = vim.fn.strdisplaywidth(chunkText)
        if usedWidth + chunkWidth <= width then
            table.insert(newVirtText, chunk)
            usedWidth = usedWidth + chunkWidth
        else
            chunkText = truncate(chunkText, width - usedWidth)
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            usedWidth = usedWidth + chunkWidth
            break
        end
        ::continue::
    end
    return newVirtText, usedWidth
end

---@type {[string]: fun(start_line: string, end_line: string): boolean?}
local ft_end = {
    ["*"] = function(start_line, end_line)
        if vim.endswith(start_line, "(") and vim.startswith(end_line, ")") then
            return true
        elseif vim.endswith(start_line, "{") and vim.startswith(end_line, "}") then
            return true
        elseif vim.endswith(start_line, "[") and vim.startswith(end_line, "]") then
            return true
        elseif vim.endswith(start_line, "`") and vim.startswith(end_line, "`") then
            return true
        elseif start_line:match("{{{") and end_line:match("}}}") then
            return true
        end
    end,
    html = function(start_line, end_line)
        if vim.startswith(end_line, "</") then
            return true
        end
    end,
    javascript = function(start_line, end_line)
        if vim.startswith(end_line, "</") then
            return true
        elseif start_line:match("`") and end_line:match("`") then
            return true
        end
    end,
    lua = function(start_line, end_line)
        if vim.startswith(end_line, "end") then
            return true
        elseif start_line:match("repeat") and end_line:match("until") then
            return true
        end
    end,
    markdown = function(start_line, end_line)
        if start_line:match("```") and end_line:match("```") then
            return true
        end
    end,
    python = function(start_line, end_line)
        if start_line:match('"""') and end_line:match('"""') then
            return true
        elseif start_line:match("'''") and end_line:match("'''") then
            return true
        elseif start_line:match("%[%s-#.*") and vim.startswith(end_line, "]") then
            return true
        elseif start_line:match("%(%s-#.*") and vim.startswith(end_line, ")") then
            return true
        elseif start_line:match("{%s-#.*") and vim.startswith(end_line, "}") then
            return true
        end
    end,
    ruby = function(start_line, end_line)
        if vim.startswith(end_line, "end") then
            return true
        end
    end,
    sh = function(start_line, end_line)
        if vim.startswith(end_line, "fi") then
            return true
        elseif vim.startswith(end_line, "esac") then
            return true
        elseif vim.startswith(end_line, "done") then
            return true
        elseif start_line:match("<<%-?%s-['\"]?%w+['\"]?$") then
            local eof = start_line:match("<<%-?%s-['\"]?(%w+)['\"]?$")
            if end_line == eof then
                return true
            end
        end
    end,
    vim = function(start_line, end_line)
        if vim.startswith(end_line, "augroup") then
            return true
        elseif vim.startswith(end_line, "endif") then
            return true
        elseif vim.startswith(end_line, "endfunction") then
            return true
        elseif vim.startswith(end_line, "endfor") then
            return true
        elseif vim.startswith(end_line, "endwhile") then
            return true
        elseif vim.startswith(end_line, "endtry") then
            return true
        end
    end,
}
ft_end.bash = ft_end.sh
ft_end.zsh = ft_end.sh

---@param filetype string
---@param start_line string
---@param end_line string
---@return boolean?
local function contain_end_line(filetype, start_line, end_line)
    return ft_end[filetype] and ft_end[filetype](start_line, end_line) or ft_end["*"](start_line, end_line)
end

-- Customize fold text
-- use setup: fold_virt_text_handler = handler
local function handler(virtText, lnum, endLnum, width, truncate, ctx)
    local newVirtText = {}
    local usedWidth = 0
    -- fold start line
    local startVirt, start_width = addVirtText(virtText, width, truncate, false)
    for _, item in ipairs(startVirt) do
        table.insert(newVirtText, item)
    end
    usedWidth = usedWidth + start_width
    if usedWidth >= width then
        return newVirtText
    end
    -- fold end line
    local endVirtText = ctx.get_fold_virt_text(endLnum)
    local start_content = vim.trim(vim.fn.getline(lnum))
    local end_content = vim.trim(vim.fn.getline(endLnum))
    local filetype = vim.bo.filetype
    local show_end_line = contain_end_line(filetype, start_content, end_content)
    if show_end_line then
        table.insert(newVirtText, { " ••• ", "UfoFoldedFg" })
        usedWidth = usedWidth + 5
        local endVirt, end_width = addVirtText(endVirtText, width - usedWidth, truncate, true)
        local remove_start_blank = true
        for _, item in ipairs(endVirt) do
            if remove_start_blank and string.match(item[1], "^%s") then
                end_width = end_width - #item[1]
                item[1] = string.gsub(item[1], "^%s*", "")
                end_width = end_width + #item[1]
            end
            if #item[1] > 0 then
                remove_start_blank = false
            end
            table.insert(newVirtText, item)
        end
        usedWidth = usedWidth + end_width
    end
    if usedWidth >= width then
        return newVirtText
    end
    -- fold right
    local folded_lines = endLnum - lnum + 1
    local all_lines = vim.fn.line("$")
    local percentage = math.floor(folded_lines / all_lines * 100)
    local fold_right = string.format(" %s lines:%3s%% •••", folded_lines, percentage)
    table.insert(newVirtText, { " ", "UfoFoldedFg" })
    usedWidth = usedWidth + 1
    local count = width - usedWidth - vim.fn.strdisplaywidth(fold_right)
    table.insert(newVirtText, { string.rep("•", count), "UfoFoldedFg" })
    table.insert(newVirtText, { fold_right, "UfoFoldedFg" })
    return newVirtText
end

local ftMap = {
    css = "treesitter",
    go = "treesitter",
    html = "treesitter",
    javascript = "treesitter",
    json = "treesitter",
    jsonc = "treesitter",
    lua = "treesitter",
    swift = "treesitter",
    typescript = "treesitter",
    vim = "treesitter",
}

require("ufo").setup({
    enable_get_fold_virt_text = true,
    close_fold_kinds_for_ft = {
        default = { "imports", "comment" },
        html = {},
        http = {},
        xml = {},
        gitcommit = {},
    },
    preview = {
        mappings = {
            scrollU = "<c-u>",
            scrollD = "<c-d>",
            jumpTop = "[",
            jumpBot = "]",
        },
    },
    provider_selector = function(bufnr, filetype, buftype)
        if filetype == "asciidoc" then
            --- create folds by	`vim.g.asciidoc_folding = 1`
            ---	:help ft-asciidoc-plugin
            return ""
        end
        if vim.tbl_get(ftMap, filetype) then
            return function()
                return getFoldsWithCustom(bufnr, ftMap[filetype])
            end
        end
        return customizeSelector
    end,
    fold_virt_text_handler = handler,
})

vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
vim.keymap.set("n", "zm", require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
vim.keymap.set("n", "K", function()
    local winid = require("ufo").peekFoldedLinesUnderCursor()
    if not winid then
        vim.cmd("Lspsaga hover_doc")
    end
end)

vim.api.nvim_create_autocmd("FileType", {
    ---@param args {buf: number, event: string, file: string, id: number, match: string}
    callback = function(args)
        local buftype = vim.bo[args.buf].buftype
        local bufname = vim.api.nvim_buf_get_name(args.buf)
        if buftype == "" and bufname == "" then
            local ufo = require("ufo")
            if ufo.hasAttached(args.buf) then
                ufo.detach(args.buf)
                ufo.attach(args.buf)
            end
        end
    end,
})
