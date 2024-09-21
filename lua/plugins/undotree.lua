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
vim.g.undotree_DiffpanelHeight = 15

vim.g.undotree_TreeNodeShape = "•"
vim.g.undotree_TreeReturnShape = "─╮"
vim.g.undotree_TreeVertShape = "│"
vim.g.undotree_TreeSplitShape = "─╯"
if vim.env.KITTY_INSTALLATION_DIR then
    vim.g.undotree_TreeNodeShape = ""
    vim.g.undotree_TreeReturnShape = ""
    vim.g.undotree_TreeVertShape = ""
    vim.g.undotree_TreeSplitShape = ""
end

vim.keymap.set("n", "<m-9>", "<cmd>UndotreeToggle<cr>", { silent = true })
