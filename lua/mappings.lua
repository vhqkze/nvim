--help: https://github.com/nanotee/nvim-lua-guide

-- see :help map-modes
-- defining mappings: https://github.com/nanotee/nvim-lua-guide#defining-mappings
--      COMMANDS                    MODES
-- :map   :noremap  :unmap     Normal, Visual, Select, Operator-pending
-- :nmap  :nnoremap :nunmap    Normal
-- :vmap  :vnoremap :vunmap    Visual and Select
-- :smap  :snoremap :sunmap    Select
-- :xmap  :xnoremap :xunmap    Visual
-- :omap  :onoremap :ounmap    Operator-pending
-- :map!  :noremap! :unmap!    Insert and Command-line
-- :imap  :inoremap :iunmap    Insert
-- :lmap  :lnoremap :lunmap    Insert, Command-line, Lang-Arg
-- :cmap  :cnoremap :cunmap    Command-line
-- :tmap  :tnoremap :tunmap    Terminal

-- vim.keymap.set 有默认选项 remap=false
local default_opts = { silent = true }

-- more natural movement with wrap on
-- vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", expr_opts)
-- vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", expr_opts)
vim.keymap.set({ "n", "x" }, "j", "gj", default_opts)
vim.keymap.set({ "n", "x" }, "k", "gk", default_opts)

-- Reselect visual block after indent/outdent
vim.keymap.set("x", "<", "<gv", default_opts)
vim.keymap.set("x", ">", ">gv", default_opts)
-- don't jump when using *
-- vim.keymap.set("n", "*", "*<c-o>", default_opts)

-- paste over currently selected text without yanking it
vim.keymap.set("x", "p", '"0P', default_opts)

-- cancel search highlighting with esc
vim.keymap.set("n", "<ESC>", ":nohlsearch<Bar>:echo<cr>", default_opts)

-- move selected line / block of text in visual mode
vim.keymap.set("x", "K", ":move '<-2<cr>gv=gv", default_opts)
vim.keymap.set("x", "J", ":move '>+1<cr>gv=gv", default_opts)

-- center search results
vim.keymap.set("n", "n", "nzz", default_opts)
vim.keymap.set("n", "N", "Nzz", default_opts)
vim.keymap.set("n", "*", "*zz", default_opts)
vim.keymap.set("n", "#", "#zz", default_opts)

vim.keymap.set("i", "<c-e>", "<cmd>normal <c-e><cr>", default_opts)
vim.keymap.set("i", "<c-y>", "<cmd>normal <c-y><cr>", default_opts)
vim.keymap.set("i", "<c-z>", "<cmd>normal zz<cr>", default_opts)

vim.keymap.set("t", "<esc>", "<c-\\><c-n>", default_opts)
vim.keymap.set("t", "<c-q>", "<c-\\><c-n>", default_opts)

vim.keymap.set("s", "<backspace>", "b<backspace>", default_opts)
vim.keymap.set("s", "<del>", "<c-o>c", default_opts)
vim.keymap.set("s", "<right>", "<c-g>o<esc>a", default_opts)
vim.keymap.set("s", "<left>", "<esc>i", default_opts)

-- vim-easy-align
vim.keymap.set({ "x", "n" }, "ga", "<Plug>(EasyAlign)", default_opts)

vim.keymap.set({ "n", "x" }, "<m-z>", function()
    vim.o.wrap = not vim.o.wrap
end, { silent = true, desc = "Toggle wrap" })

-- diagnostic
vim.keymap.set("n", "<leader>dt", function()
    vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { silent = true, desc = "Toggle diagnostic" })

vim.keymap.set({ "n" }, "<S-ScrollWheelLeft>", "<ScrollWheelLeft>", default_opts)
vim.keymap.set({ "n" }, "<S-ScrollWheelRight>", "<ScrollWheelRight>", default_opts)

vim.keymap.set({ "n", "i" }, "<home>", function()
    -- 按home键在行首第一个字符和第一个非空字符之间跳转
    local pos = vim.fn.col(".")
    if pos == 1 then
        vim.cmd("normal ^")
    else
        vim.cmd("normal ^")
        if pos == vim.fn.col(".") then
            vim.cmd("normal 0")
        end
    end
end, { silent = true, desc = "Go to 0 or ^" })

-- restore cursor position before undo/redo
vim.keymap.set("n", "u", function()
    local cursor_before = vim.fn.getpos(".")
    vim.cmd("undo")
    vim.cmd("redo")
    local cursor_after = vim.fn.getpos(".")
    if vim.deep_equal(cursor_after, cursor_before) then
        vim.cmd("undo")
    end
end)
vim.keymap.set("n", "<c-r>", function()
    local cursor_before = vim.fn.getpos(".")
    vim.cmd("redo")
    vim.cmd("undo")
    local cursor_after = vim.fn.getpos(".")
    if vim.deep_equal(cursor_after, cursor_before) then
        vim.cmd("redo")
    end
end)
