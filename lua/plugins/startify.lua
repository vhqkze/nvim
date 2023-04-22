vim.g.startify_session_dir = vim.fn.stdpath("data") .. "/sessions"
vim.g.startify_padding_left = 12

---get all session files
---@return table
local function get_sessions()
    local sessions_dir = vim.g.startify_session_dir
    local files_with_abspath = vim.fn.split(vim.fn.globpath(sessions_dir, "*.vim"), "\n")
    files_with_abspath = vim.fn.sort(files_with_abspath, function(i1, i2)
        if vim.fn.getftime(i1) > vim.fn.getftime(i2) then
            return -1
        elseif vim.fn.getftime(i1) < vim.fn.getftime(i2) then
            return 1
        else
            return 0
        end
    end)
    local files = vim.fn.map(files_with_abspath, 'fnamemodify(v:val, ":t")')
    local sessions = {}
    for _, file in ipairs(files) do
        if vim.endswith(file, ".vim") then
            local display_name = file:gsub("%%", "/")
            table.insert(sessions, { line = display_name, cmd = "SLoad " .. file })
        end
    end
    return sessions
end

local padding_left = string.rep(' ', vim.g.startify_padding_left)
vim.g.startify_lists = {
    { type = get_sessions, header = { padding_left .. "Sessions" } },
    { type = "files",      header = { padding_left .. "Recent files" } },
    { type = "dir",        header = { padding_left .. "Recent files in " .. vim.fn.getcwd() } },
    { type = "bookmarks",  header = { padding_left .. "Bookmarks" } },
}
