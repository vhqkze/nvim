local Terminal = require("toggleterm.terminal").Terminal
local module_name = "Runner"
local M = {}
M.runner = nil
M.filetype = {
    bash = "bash $file",
    go = "go run $file",
    java = "javac $fileName && java $fileNameWithoutExt",
    lua = ":luafile %",
    markdown = ":MarkdownPreview",
    python = "python3 -u $file",
    rust = "rustc $file && $fileNameWithoutExt",
    sh = "bash $file",
    swift = "swift $file",
    typescript = "deno run $file",
    vim = ":source %",
    zsh = "zsh $file",
}
M.stay = true -- stay focus current window

--- toggle terminal
---@param state boolean 目标状态
function M.toggle(state)
    if M.runner ~= nil then
        local is_open = M.runner:is_open()
        if state == true and not is_open then
            M.runner:open()
        elseif state == false and is_open then
            M.runner:close()
        elseif state == nil then
            M.runner:toggle()
        end
    end
end

local function terminal_run(cmd, display_name, dir)
    if cmd == nil or cmd == "" then
        vim.notify("no command", vim.log.levels.WARN, { title = module_name })
        return
    end
    if M.runner ~= nil and M.runner:is_open() then
        M.runner:close()
    end
    local current_window = vim.api.nvim_get_current_win()
    M.runner = Terminal:new({
        cmd = cmd,
        hidden = true,
        dir = dir or "git_dir",
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
        end,
        on_stderr = function()
            vim.notify("task stderr", vim.log.levels.ERROR, { title = module_name })
        end,
        on_exit = function(t, job, exit_code, name)
            local out = { text = "Success!", level = "info" }
            if exit_code ~= 0 then
                out = { text = "Failure!", level = "error" }
            end
            vim.notify("Job finished: " .. out.text, out.level, { title = t.display_name })
            require("util").system_notify("task finished.", module_name)
        end,
    })
    M.runner.display_name = display_name or cmd:gsub("^.-::", "")
    M.runner:open()
    return M.runner
end

local function parse_cmd(command)
    local fileNameWithoutExt = vim.fn.shellescape(vim.fn.expand("%:t:r"))
    local fileName = vim.fn.shellescape(vim.fn.expand("%:t")) -- filename, without path
    local file = vim.fn.shellescape(vim.fn.expand("%:p")) -- absolute path
    local dir = vim.fn.shellescape(vim.fn.expand("%:p:h"))
    command = command:gsub("$fileNameWithoutExt", fileNameWithoutExt)
    command = command:gsub("$fileName", fileName)
    command = command:gsub("$file", file)
    command = command:gsub("$dir", dir)
    return command
end

function M.run_file()
    local ft_cmd = M.filetype[vim.bo.filetype]
    if ft_cmd == nil then
        vim.notify("filetype not supported", vim.log.levels.WARN, { title = module_name })
        return
    end
    if type(ft_cmd) == "string" and ft_cmd:sub(1, 1) == ":" then
        local cmd = vim.api.nvim_parse_cmd(ft_cmd:sub(2), {})
        local output = vim.api.nvim_cmd(cmd, { output = true })
        output = output == "" and "Success without output." or output
        vim.notify(output, vim.log.levels.INFO, { title = module_name })
        return
    end
    local cmd = parse_cmd(ft_cmd)
    terminal_run(cmd, module_name, nil)
end

return M
