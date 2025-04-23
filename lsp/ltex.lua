local language_id_mapping = {
    bib = "bibtex",
    plaintex = "tex",
    rnoweb = "rsweave",
    rst = "restructuredtext",
    tex = "latex",
    pandoc = "markdown",
    text = "plaintext",
}

local filetypes = {
    "asciidoc",
    "gitcommit",
    "html",
    "latex",
    "mail",
    "markdown",
    "org",
    "plaintex",
    "restructuredtext",
    "rst",
    "text",
}

local function get_language_id(_, filetype)
    return language_id_mapping[filetype] or filetype
end

local enabled_ids = {}
do
    local enabled_keys = {}
    for _, ft in ipairs(filetypes) do
        local id = get_language_id({}, ft)
        if not enabled_keys[id] then
            enabled_keys[id] = true
            table.insert(enabled_ids, id)
        end
    end
end

return {
    cmd = { "ltex-ls" },
    filetypes = filetypes,
    root_markers = { ".git" },
    settings = {
        ltex = {
            enabled = enabled_ids,
            language = "zh-CN",
            dictionary = {
                ["en-US"] = { "Neovim", "LuaJIT" },
            },
            checkFrequency = "save",
        },
    },
}
