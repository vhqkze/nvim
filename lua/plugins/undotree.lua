if vim.fn.has("persistent_undo") == 1 then
    local target_path = vim.fn.stdpath("cache") .. "/undodir"
    if vim.fn.isdirectory(target_path) == 0 then
        vim.cmd('call mkdir("' .. target_path .. '", "p", 0700)')
    end
    vim.opt.undodir = target_path
    vim.opt.undofile = true
end

vim.g.undotree_WindowLayout = 2
vim.g.undotree_SetFocusWhenToggle = 1
vim.g.undotree_HelpLine = 0
vim.g.undotree_DiffCommand = "diff -u"

vim.keymap.set("n", "<m-9>", "<cmd>UndotreeToggle<cr>", { silent = true })
