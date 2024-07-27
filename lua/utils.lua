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

function M.system_notify(content, title, subtitle, sound)
    if vim.fn.has("mac") == 1 then
        local cmd = string.format('display notification "%s"', content)
        if title ~= nil then
            cmd = cmd .. string.format(' with title "%s"', title)
        end
        if subtitle ~= nil then
            cmd = cmd .. string.format(' with subtitle "%s"', subtitle)
        end
        if sound ~= nil then
            cmd = cmd .. string.format(' sound name "%s"', sound)
        end
        vim.system({ "osascript", "-e", cmd })
    end
end

return M
