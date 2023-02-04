-- If you are using tmux, run these steps first: enabling OSC52 in tmux.
-- Then make sure set-clipboard is set to on: set -s set-clipboard on.

require("osc52").setup({
    max_length = 0, -- Maximum length of selection (0 for no limit)
    silent = false, -- Disable message on successful copy
    trim = false, -- Trim text before copy
})

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        if vim.v.event.operator == "y" and vim.v.event.regname == "c" then
            require("osc52").copy_register("c")
        end
    end,
})

-- vim.keymap.set("n", "<leader>c", require("osc52").copy_operator, { expr = true })
-- vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
-- vim.keymap.set("x", "<leader>c", require("osc52").copy_visual)
