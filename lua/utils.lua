local M = {}

---get highligh color
---@param name string highlight name
---@param key? string see :h synIDattr
---@return string # empty if error
function M.get_hl(name, key)
    -- :help synIDattr
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.api.nvim_get_hl_id_by_name(name)), key)
end

--- save content to file
---@param content table | string
---@param filename string
---@param mode? string
---@return boolean
function M.save_to_file(content, filename, mode)
    if type(content) == "table" then
        local result = vim.fn.writefile(content, filename, mode or "w")
        return result == 0
    end
    local file = io.open(filename, mode or "w")
    if not file then
        return false
    end
    file:write(content)
    file:close()
    return true
end

--- send system notification
---@param content string
---@param title? string
---@param sound? string
function M.system_notify(content, title, sound)
    title = title or "Neovim"
    if vim.env.TERM == "xterm-kitty" then
        local msg = string.format("\x1b]99;i=1:d=0:p=title;%s\x1b\\\x1b]99;i=1:d=1:p=body;%s\x1b\\", title, content)
        io.write(msg)
        return
    end
    if vim.fn.has("mac") == 1 then
        local cmd = string.format('display notification "%s"', content)
        if sound ~= nil then
            cmd = cmd .. string.format(' sound name "%s"', sound)
        end
        vim.system({ "osascript", "-e", cmd })
        return
    end
end

return M
