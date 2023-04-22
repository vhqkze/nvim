local M = {}

---get highligh color
---@param name string highlight name
---@param key? string see :h synIDattr
---@return string # empty if error
function M.get_hl(name, key)
    -- :help synIDattr
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.api.nvim_get_hl_id_by_name(name)), key)
end

return M
