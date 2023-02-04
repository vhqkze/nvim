local notify = require("notify")
-- use tab to navigate completion menu
local check_back_space = function()
    local col = vim.fn.col(".") - 1
    return col == 0 or vim.fn.getline("."):sub(col, col):match("%s") ~= nil
end

--vim.keymap.set('i', '<Tab>', function()
--    return vim.fn.pumvisible() == 1 and '<C-N>' or (check_back_space() and '<Tab>' or vim.fn['coc#refresh']())
--end, {expr = true, silent = true})

--vim.keymap.set('i', '<S-Tab>', function()
--    return vim.fn.pumvisible() == 1 and '<C-p>' or '<C-h>'
--end, {expr = true, silent = true})

local termcodes = function(string)
    return vim.api.nvim_replace_termcodes(string, true, true, true)
end

function tab_completion()
    print("pumvisible:" .. vim.fn.pumvisible())
    if vim.fn.pumvisible() ~= 0 then
        print(vim.fn.pumvisible())
        return vim.fn["coc#_select_confirm"]()
    elseif vim.fn["coc#expandableOrJumpable"]() then
        return termcodes("<c-r>") .. "=coc#rpc#request('doKeymap', ['snippets-expand-jump', ''])" .. termcodes("<cr>")
    elseif check_back_space() then
        return termcodes("<Tab>")
    else
        return vim.fn["coc#refresh"]()
    end
end

vim.keymap.set("i", "<Tab>", "v:lua.tab_completion()", { expr = true, silent = true, noremap = true })
-- vim.g.coc_snippet_next = '<Tab>'

function cr_completion()
    if vim.fn.pumvisible() ~= 0 then
        return vim.fn["coc#_select_confirm"]()
    else
        return vim.api.nvim_replace_termcodes("<cr>", true, true, true)
    end
end

vim.keymap.set("i", "<cr>", "v:lua.cr_completion()", { expr = true, silent = true })

-- " Use `[g` and `]g` to navigate diagnostics
-- " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
-- nmap <silent> [g <Plug>(coc-diagnostic-prev)
-- nmap <silent> ]g <Plug>(coc-diagnostic-next)
vim.keymap.set("n", "[g", "<Plug>(coc-diagnostic-prev)", { silent = true })
vim.keymap.set("n", "]g", "<Plug>(coc-diagnostic-next)", { silent = true })

-- -- goto code navigation
vim.keymap.set("n", "gd", "<Plug>(coc-definition)", { silent = true })
vim.keymap.set("n", "gy", "<Plug>(coc-type-definition)", { silent = true })
vim.keymap.set("n", "gi", "<Plug>(coc-implementation)", { silent = true })
vim.keymap.set("n", "gr", "<Plug>(coc-references)", { silent = true })

-- Use K to show documentation in preview window
vim.keymap.set("n", "K", function()
    -- return vim.fn.CocAction('hasProvider', 'hover') == true and vim.fn.CocActionAsync('doHover') or
    return vim.fn.CocHasProvider("hover") and vim.fn.CocActionAsync("doHover") or vim.fn.feedkeys("K", "in")
end, { expr = true, silent = true, desc = "coc do hover" })

-- Highlight the symbol and its references when holding the cursor.
vim.cmd([[autocmd CursorHold * silent call CocActionAsync('highlight')]])

-- Symbol renaming
vim.keymap.set("n", "<leader>rn", "<Plug>(coc-rename)", { silent = true })

function show_signature()
    return vim.cmd("<C-r>=CocActionAsync('showSignatureHelp')<CR>")
end

vim.keymap.set("i", "<C-p>", "v:lua.show_signature()", { expr = true, silent = true, noremap = true })

-- format code
vim.keymap.set("n", "<leader>fm", '<cmd>call CocActionAsync("format")<cr>', { silent = true })
vim.keymap.set({ "v", "x" }, "<leader>fm", '<cmd>call CocActionAsync("formatSelected")<cr>', { silent = true })

-- Applying codeAction to the selected region.
vim.keymap.set({ "n", "x" }, "<leader>a", "<Plug>(coc-codeaction-selected)", { silent = true })
-- Remap keys for applying codeAction to the current buffer.
vim.keymap.set("n", "<leader>ac", "<Plug>(coc-codeaction)", { silent = true })
-- Apply AutoFix to problem on the current line.
vim.keymap.set("n", "<leader>qf", "<Plug>(coc-fix-current)", { silent = true })
-- Run the Code Lens action on the current line.
-- vim.keymap.set('n', '<leader>cl', '<Plug>(coc-codelens-action)', {silent=true})

-- Remap <C-f> and <C-b> for scroll float windows/popups.
function scroll_down()
    return vim.fn["coc#float#has_scroll"]() == 1 and vim.fn["coc#float#scroll"](1) or vim.api.nvim_replace_termcodes("<c-d>", true, true, true)
end

vim.keymap.set({ "n", "i", "v" }, "<c-d>", "v:lua.scroll_down()", { silent = true, expr = true, nowait = true })

function scroll_up()
    return vim.fn["coc#float#has_scroll"]() == 1 and vim.fn["coc#float#scroll"](0) or vim.api.nvim_replace_termcodes("<c-u>", true, true, true)
end

vim.keymap.set({ "n", "i", "v" }, "<c-u>", "v:lua.scroll_up()", { silent = true, expr = true, nowait = true })
