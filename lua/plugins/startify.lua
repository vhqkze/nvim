function list_session()
    local sessions_dir = vim.fn.stdpath("data") .. "/sessions"
    local pfile = io.popen("cd " .. sessions_dir .. "&& ls -t " .. "*.vim")
    local result = {}
    for filename in pfile:lines() do
        local show_name = filename:gsub("%%", "/")
        table.insert(result, { line = show_name, cmd = "SLoad " .. filename, path = "" })
    end
    pfile:close()
    return result
end

vim.g.startify_lists = {
    { type = list_session, header = { "   Sessions" } },
    { type = "files", header = { "   Recent files" } },
    { type = "dir", header = { "   Recent files in " .. vim.fn.getcwd() } },
    { type = "bookmarks", header = { "   Bookmarks" } },
}
vim.g.startify_session_dir = vim.fn.stdpath("data") .. "/sessions"
vim.g.startify_session_sort = 1
