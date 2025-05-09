require("gitsigns").setup({
    attach_to_untracked = true,
    preview_config = {
        border = "rounded",
    },
    sign_priority = 100,
    culhl = true,
    on_attach = function(bufnr)
        local gs = require("gitsigns")

        local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gs.nav_hunk("next", { preview = true })
            end
        end, { silent = true, desc = "Gitsigns next_hunk" })

        map("n", "[c", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gs.nav_hunk("prev", { preview = true })
            end
        end, { silent = true, desc = "Gitsigns prev_hunk" })

        -- Actions
        map("n", "<leader>hs", gs.stage_hunk, { silent = true, desc = "Gitsigns stage_hunk" })
        map("n", "<leader>hr", gs.reset_hunk, { silent = true, desc = "Gitsigns reset_hunk" })
        map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { silent = true, desc = "Gitsigns stage_selected" })
        map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, { silent = true, desc = "Gitsigns reset_selected" })
        map("n", "<leader>hS", gs.stage_buffer, { silent = true, desc = "Gitsigns stage_buffer" })
        map("n", "<leader>hR", gs.reset_buffer, { silent = true, desc = "Gitsigns reset_buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { silent = true, desc = "Gitsigns preview_hunk" })
        map("n", "<leader>hi", gs.preview_hunk_inline, { silent = true, desc = "Gitsigns preview_hunk_inline" })
        map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
        end, { silent = true, desc = "Gitsigns blame_line" })
        map("n", "<leader>hd", gs.diffthis, { silent = true, desc = "Gitsigns diffthis" })
        map("n", "<leader>hD", function()
            gs.diffthis("~")
        end, { silent = true, desc = "Gitsigns diffthis~" })
        map("n", "<leader>hQ", function()
            gs.setqflist("all")
        end, { silent = true, desc = "Gitsigns quickfix all" })
        map("n", "<leader>hq", gs.setqflist, { silent = true, desc = "Gitsigns quickfix" })

        -- Toggles
        map("n", "<leader>tb", gs.toggle_current_line_blame, { silent = true, desc = "Gitsigns toggle_current_line_blame" })
        map("n", "<leader>td", gs.toggle_deleted, { silent = true, desc = "Gitsigns toggle_deleted" })
        map("n", "<leader>tw", gs.toggle_word_diff, { silent = true, desc = "Gitsigns toggle_word_diff" })

        -- Text object
        map({ "o", "x" }, "ih", gs.select_hunk, { silent = true, desc = "Gitsigns select_hunk" })
    end,
})
