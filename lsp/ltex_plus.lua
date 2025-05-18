---see: https://github.com/ltex-plus/ltex-ls-plus/blob/develop/src/main/kotlin/org/bsplines/ltexls/tools/FileIo.kt
local language_id_mapping = {
    bash = "shellscript",
    sh = "shellscript",
    fish = "shellscript",
    bib = "bibtex",
    norg = "neorg",
    pandoc = "markdown",
    plaintex = "latex",
    rnoweb = "rsweave",
    rst = "restructuredtext",
    tex = "latex",
    text = "plaintext",
    xhtml = "html",
    zsh = "shellscript",
}

local filetypes = {
    "asciidoc",
    "gitcommit",
    "html",
    "mail",
    "markdown",
    "norg",
    "org",
    "pandoc",
    "plaintex",
    "rst",
    "text",
    "typst",
    "xhtml",
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
    cmd = { "ltex-ls-plus" },
    filetypes = filetypes,
    root_markers = { ".git" },
    get_language_id = get_language_id,
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
