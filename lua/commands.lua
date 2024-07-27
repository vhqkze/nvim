-- My custom commands
local utils = require("utils")

vim.api.nvim_create_user_command("BD", "bp|bd #", { desc = "buf delete without change layout" })
vim.api.nvim_create_user_command("BDD", "bp|bd! #", { desc = "buf delete force without change layout" })

--- diff with clipboard
---@param opts {range: number, line1: number, line2: number}
local function diff_with_clipboard(opts)
    local content_clipboard = vim.fn.getreg("+")
    if vim.trim(content_clipboard) == "" then
        vim.notify("clipboard is empty!", vim.log.levels.ERROR, { title = "DiffClipboard" })
        return
    end
    local file_clipboard = vim.fn.tempname() .. "_clipboard"
    utils.save_to_file(content_clipboard, file_clipboard)
    if opts.range == 0 then
        vim.cmd("tab split")
        vim.cmd("diffsplit " .. file_clipboard)
    else
        local selection = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)
        local file_selection = vim.fn.tempname() .. "_selection"
        vim.fn.writefile(selection, file_selection)
        vim.cmd("tabedit " .. file_selection)
        vim.cmd("diffsplit " .. file_clipboard)
    end
end

vim.api.nvim_create_user_command("DiffClipboard", diff_with_clipboard, { range = true, desc = "diff with clipboard" })

--- reverse lines, only work for visual mode
---@param opts {line1: number, line2: number}
local reverse_lines = function(opts)
    if opts.line1 == opts.line2 then
        return
    end
    local lines = vim.api.nvim_buf_get_lines(0, opts.line1 - 1, opts.line2, true)
    local i, j = 1, #lines
    while i < j do
        lines[i], lines[j] = lines[j], lines[i]
        i, j = i + 1, j - 1
    end
    vim.api.nvim_buf_set_lines(0, opts.line1 - 1, opts.line2, true, lines)
end

vim.api.nvim_create_user_command("Reverse", reverse_lines, { range = true })
