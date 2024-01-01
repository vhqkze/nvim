vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

-- lsp->treesitter->indent
local function customizeSelector(bufnr)
    local function handleFallbackException(err, providerName)
        if type(err) == "string" and err:match("UfoFallbackException") then
            return require("ufo").getFolds(bufnr, providerName)
        else
            return require("promise").reject(err)
        end
    end

    return require("ufo")
        .getFolds(bufnr, "lsp")
        :catch(function(err)
            return handleFallbackException(err, "treesitter")
        end)
        :catch(function(err)
            return handleFallbackException(err, "indent")
        end)
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
    local show_end_line = false
    local need_end_ft = { "go", "toml", "java", "javascript", "json", "jsonc" }
    if vim.tbl_contains(need_end_ft, filetype) then
        show_end_line = show_end_line or end_content:match("^%s-[}%])]")
    elseif filetype == "python" then
        show_end_line = show_end_line or end_content:match("^%s-[}%])]")
        show_end_line = show_end_line or end_content:match([[^%s-"""]])
    elseif filetype == "lua" then
        show_end_line = show_end_line or end_content:match("^%s-[}%])]")
        show_end_line = show_end_line or end_content:match("^%s-end")
    elseif vim.tbl_contains({ "sh", "bash", "zsh" }, filetype) then
        show_end_line = show_end_line or end_content:match("^%s-[}%])]")
        show_end_line = show_end_line or end_content:match("^%s-fi")
        show_end_line = show_end_line or end_content:match("^%s-esac")
    elseif filetype == "vim" then
        show_end_line = show_end_line or end_content:match("^%s-[}%])]")
        show_end_line = show_end_line or end_content:match("^%s-endif")
        show_end_line = show_end_line or end_content:match("^%s-endfunction")
    elseif filetype == "markdown" then
        show_end_line = show_end_line or end_content:match("^%s-```")
    end
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
    go = "treesitter",
    json = "treesitter",
    jsonc = "treesitter",
    lua = "treesitter",
    swift = "treesitter",
    vim = "treesitter",
}

require("ufo").setup({
    enable_get_fold_virt_text = true,
    close_fold_kinds = { "imports", "comment" },
    provider_selector = function(bufnr, filetype, buftype)
        return ftMap[filetype] or customizeSelector
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
        vim.lsp.buf.hover()
    end
end)
