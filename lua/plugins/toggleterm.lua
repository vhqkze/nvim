require("toggleterm").setup({
    shade_terminals = false,
    on_open = function()
        vim.opt_local.signcolumn = "no"
    end,
    hide_numbers = true,
    open_mapping = "<c-_>",
    insert_mappings = true,
    terminal_mappings = true,
})

vim.keymap.set("t", "<m-8>", "<cmd>88ToggleTerm<cr>", { silent = true })

vim.keymap.set("n", "<m-8>", function()
    local console = require("toggleterm.terminal").get(88)
    if console then -- 已经有console
        return vim.cmd("88ToggleTerm")
    end
    -- 没有console， 创建console
    local filetype = vim.bo.filetype
    local commands = {
        lua = "lua",
        python = "ipython || python3",
    }
    local command = commands[filetype]
    if command then
        local terminal = require("toggleterm.terminal").Terminal:new({ cmd = command, count = 88 })
        terminal:toggle()
        terminal.display_name = "Console"
    end
end, { silent = true })

local pytest = require("pytest")
vim.keymap.set("n", "<leader>nc", pytest.run_class, { silent = true, desc = "pytest class" })
vim.keymap.set("n", "<leader>nn", pytest.run_function, { silent = true, desc = "pytest function" })
vim.keymap.set("n", "<leader>nl", pytest.rerun_last_test, { silent = true, desc = "rerun last command" })
vim.keymap.set("n", "<leader>ne", pytest.rerun_failed_tests, { silent = true, desc = "rerun failed tests" })
vim.keymap.set("n", "<leader>no", pytest.toggle, { silent = true, desc = "toggle console" })
