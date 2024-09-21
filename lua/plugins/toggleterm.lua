local Terminal = require("toggleterm.terminal").Terminal

require("toggleterm").setup({
    shade_terminals = false,
    hide_numbers = true,
    open_mapping = vim.env.TMUX == nil and "<c-/>" or "<c-_>",
    insert_mappings = true,
    terminal_mappings = true,
})

---@param filetype string
---@return string|nil
local function get_command_by_ft(filetype)
    ---@type table<string, string[]>
    local ft_commands = {
        java = { "jshell" },
        javascript = { "node" },
        lua = { "lua", "luajit" },
        python = { "ipython", "python3" },
        ruby = { "irb" },
        swift = { "swift" },
    }
    local commands = ft_commands[filetype]
    if commands == nil then
        return
    end
    for _, c in ipairs(commands) do
        if vim.fn.executable(vim.split(c, " ")[1]) == 1 then
            return c
        end
    end
end

local ft_console = {}
vim.keymap.set("n", "<m-8>", function()
    local filetype = vim.bo.filetype
    if ft_console[filetype] then
        ft_console[filetype]:toggle()
        return
    end
    local command = get_command_by_ft(filetype)
    if command == nil then
        vim.notify("console command not found or not executable", vim.log.levels.WARN)
        return
    end
    local cwd = vim.fs.root(0, { ".git", "pyproject.toml", "package.json" })
    cwd = cwd or vim.uv.cwd()
    local console = Terminal:new({
        cmd = command,
        hidden = true,
        dir = cwd,
        on_open = function(term)
            vim.keymap.set({ "n", "t" }, "<m-8>", function()
                term:close()
            end, { silent = true, buffer = term.bufnr })
        end,
    })
    console:open()
    ft_console[filetype] = console
end, { silent = true, desc = "open console" })

if vim.fn.executable("lazygit") == 1 then
    local lazygit = Terminal:new({
        cmd = "lazygit",
        hidden = true,
        dir = "git_dir",
        start_in_insert = false,
        direction = "tab",
        on_create = function(term)
            vim.keymap.set({ "t" }, "<esc>", "<esc>", { silent = true, buffer = term.bufnr })
        end,
    })
    vim.keymap.set("n", "<leader>lg", function()
        lazygit:toggle()
    end, { silent = true, desc = "toggle lazygit" })
end

if vim.fn.executable("gitui") == 1 then
    local gitui = Terminal:new({
        cmd = "gitui",
        hidden = true,
        dir = "git_dir",
        start_in_insert = false,
        direction = "tab",
        on_create = function(term)
            vim.keymap.set({ "t" }, "<esc>", "<esc>", { silent = true, buffer = term.bufnr })
        end,
    })
    vim.keymap.set("n", "<leader>gu", function()
        gitui:toggle()
    end, { silent = true, desc = "toggle gitui" })
end

local runner = require("runner")
vim.keymap.set("n", "<leader>rr", runner.run_file, { silent = true, desc = "run current file" })
vim.keymap.set("n", "<leader>rl", runner.run_last_command, { silent = true, desc = "run last command" })
vim.keymap.set("n", "<leader>ro", runner.toggle, { silent = true, desc = "toggle runner window" })

local pytest = require("pytest")
vim.keymap.set("n", "<leader>nf", pytest.run_file, { silent = true, desc = "pytest file" })
vim.keymap.set("n", "<leader>nc", pytest.run_class, { silent = true, desc = "pytest class" })
vim.keymap.set("n", "<leader>nn", pytest.run_function, { silent = true, desc = "pytest function" })
vim.keymap.set("n", "<leader>nl", pytest.rerun_last_test, { silent = true, desc = "rerun last command" })
vim.keymap.set("n", "<leader>ne", pytest.rerun_failed_tests, { silent = true, desc = "rerun failed tests" })
vim.keymap.set("n", "<leader>no", pytest.toggle, { silent = true, desc = "toggle console" })
