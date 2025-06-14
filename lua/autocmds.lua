-- highlight on yank
local yankGrp = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
    -- command = "silent! lua vim.hl.on_yank({higroup='Search', timeout=800})",
    callback = function()
        vim.hl.on_yank({ higroup = "Search", timeout = 800 })
    end,
    group = yankGrp,
})

-- windows to close with "q"
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "help", "qf", "lspinfo", "list", "lspsagaoutline", "notify", "toggleterm" },
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = true })
    end,
})
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = { "terminal" },
    callback = function()
        vim.keymap.set("n", "q", "<cmd>close<cr>", { silent = true, buffer = true })
    end,
})

-- automatically jump to the last place visited
vim.api.nvim_create_autocmd("BufReadPost", {
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

vim.api.nvim_create_autocmd("TermOpen", {
    callback = function(args)
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            if vim.api.nvim_win_get_buf(win) == args.buf then
                vim.wo[win].sidescrolloff = 0
                return
            end
        end
    end,
})

-- don't load dashboard if read from stdin
vim.api.nvim_create_autocmd("StdinReadPre", {
    callback = function()
        vim.g.read_from_stdin = 1
    end,
})

local function close_old_bufs()
    ---@class Buffer
    ---@field bufnr number
    ---@field hidden number
    ---@field loaded number
    ---@field lastused number
    ---@field changed number
    ---@field name string

    ---@type Buffer[]
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    table.sort(bufs, function(a, b)
        return a.lastused < b.lastused
    end)
    local last_used_time = os.time() - 30 * 60 -- 30分钟前
    local remain = #bufs
    local pinned = vim.split(vim.g.BufferlinePinnedBuffers or "", ",", { trimempty = true })

    for _, buf in ipairs(bufs) do
        if remain <= 10 then
            break
        end
        local is_old = buf.lastused < last_used_time
        local is_changed = buf.changed == 1
        local is_invisible = buf.hidden == 1 or buf.loaded == 0
        local is_pinned = vim.tbl_contains(pinned, buf.name)
        if is_old and is_invisible and not is_changed and not is_pinned then
            vim.api.nvim_buf_delete(buf.bufnr, { force = false, unload = false })
            remain = remain - 1
        end
    end
end
---@diagnostic disable-next-line: undefined-field
local timer = vim.uv.new_timer()
timer:start(60 * 1000, 60 * 1000, vim.schedule_wrap(close_old_bufs))
