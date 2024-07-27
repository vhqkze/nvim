local navic = require("nvim-navic")
local Terminal = require("toggleterm.terminal").Terminal

local M = {}
M.console = nil
M.last_command = nil
M.stay = true -- stay focus current window
local module_name = "Pytest"

function M.is_pytest_file()
    local filename = vim.fn.expand("%:t")
    if filename:match("^test_") then
        return true
    end
    return false
end

--- toggle terminal
---@param state boolean 目标状态
function M.toggle(state)
    if M.console ~= nil then
        local is_open = M.console:is_open()
        if state == true and not is_open then
            M.console:open()
        elseif state == false and is_open then
            M.console:close()
        elseif state == nil then
            M.console:toggle()
        end
    end
end

local function run(cmd, display_name)
    if cmd == nil or cmd == "" then
        vim.notify("no command", vim.log.levels.INFO, { title = module_name })
        return
    end
    if M.console ~= nil and M.console:is_open() then
        M.console:close()
    end
    local current_window = vim.api.nvim_get_current_win()
    M.console = Terminal:new({
        cmd = "pytest --no-header -q " .. cmd,
        hidden = true,
        dir = "git_dir",
        direction = "horizontal",
        start_in_insert = false,
        close_on_exit = false,
        on_open = function(term)
            vim.opt_local.signcolumn = "no"
            vim.opt_local.foldcolumn = "0"
            vim.opt_local.statuscolumn = ""
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<c-\\><c-n>", true, true, true), "n", false)
            vim.keymap.set("n", "q", function()
                term:toggle()
            end, { silent = true, buffer = term.bufnr })
            if M.stay then
                vim.api.nvim_set_current_win(current_window)
            end
            vim.defer_fn(function()
                vim.wo[term.window].winbar = ""
            end, 0)
        end,
        on_stderr = function()
            vim.notify("task stderr", vim.log.levels.ERROR, { title = module_name })
        end,
        on_exit = function(t, job, exit_code, name)
            local out = { text = "Success!", level = "info" }
            if exit_code ~= 0 then
                out = { text = "Failure!", level = "error" }
            end
            vim.notify("Job finished: " .. out.text, out.level, { title = module_name })
            require("util").system_notify("task finished.", module_name)
        end,
    })
    M.console.display_name = display_name or cmd:gsub("^.-::", "")
    M.console:open()
    M.last_command = cmd
    return M.console
end

function M.get_function()
    local location = navic.get_data()
    if location == nil then
        return
    end
    local file = vim.fn.shellescape(vim.fn.expand("%:p"))
    local count = #location
    for i = 1, count do
        local item = location[count + 1 - i]
        if item.type == "Function" or item.type == "Method" then
            local cmd = file
            for j, value in ipairs(location) do
                if j <= count + 1 - i then
                    cmd = cmd .. "::" .. value.name
                end
            end
            return cmd
        end
    end
end

function M.get_class()
    local location = navic.get_data()
    if location == nil then
        return
    end
    local file = vim.fn.shellescape(vim.fn.expand("%:p"))
    local count = #location
    for i = 1, count do
        local item = location[count + 1 - i]
        if item.type == "Class" then
            local cmd = file
            for j, value in ipairs(location) do
                if j <= count + 1 - i then
                    cmd = cmd .. "::" .. value.name
                end
            end
            return cmd
        end
    end
end

function M.run_file()
    local file = vim.fn.shellescape(vim.fn.expand("%:p"))
    run(file)
end

function M.run_class()
    local cmd = M.get_class()
    run(cmd)
end

function M.run_function()
    local cmd = M.get_function()
    run(cmd)
end

---rerun last failed tests, When no tests failed in the last run,
---or when no cached lastfailed data was found, run no tests and exit.
function M.rerun_failed_tests()
    local cmd = "--last-failed --last-failed-no-failures none"
    run(cmd)
end

function M.rerun_last_test()
    run(M.last_command)
end

return M
