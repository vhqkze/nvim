local M = {}

---get highligh color
---@param name string highlight name
---@param key? string background, foreground, special, italic, underline, bold, undercurl, strikethrough
function M.get_hl(name, key)
    local ok, hl = pcall(vim.api.nvim_get_hl_by_name, name, true)
    if ok then
        if key == nil then
            return hl
        else
            local value = hl[key]
            if type(value) == "number" then
                return string.format("#%06x", value)
            else
                return value
            end
        end
    end
    return nil
end

return M
