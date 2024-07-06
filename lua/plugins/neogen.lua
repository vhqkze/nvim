local i = require("neogen.types.template").item

local python_rest = {
    { nil, '""" $1 """', { no_results = true, type = { "class", "func" } } },
    { nil, '"""$1', { no_results = true, type = { "file" } } },
    { nil, "", { no_results = true, type = { "file" } } },
    { nil, "$1", { no_results = true, type = { "file" } } },
    { nil, '"""', { no_results = true, type = { "file" } } },
    { nil, "", { no_results = true, type = { "file" } } },
    { nil, "# $1", { no_results = true, type = { "type" } } },
    { nil, '"""$1' },
    { nil, "" },
    { i.Parameter, ":param %s: $1", { type = { "func" } } },
    { { i.Parameter, i.Type }, ":param %s: %s, $1", { required = i.Tparam, type = { "func" } } },
    { i.ClassAttribute, ":param %s: $1" },
    { i.Throw, ":raises %s: $1", { type = { "func" } } },
    { i.Return, ":return: $1", { type = { "func" } } },
    { i.ReturnTypeHint, ":return: $1", { type = { "func" } } },
    { nil, '"""' },
}

require("neogen").setup({
    snippet_engine = "luasnip",
    languages = {
        python = {
            template = {
                -- annotation_convention = "reST",
                annotation_convention = "python_template",
                python_template = python_rest,
            },
        },
    },
    placeholders_text = {
        ["description"] = "[description]",
        ["tparam"] = "[tparam]",
        ["parameter"] = "[parameter]",
        ["return"] = "",
        ["class"] = "[class]",
        ["throw"] = "[throw]",
        ["varargs"] = "[varargs]",
        ["type"] = "[type]",
        ["attribute"] = "[attribute]",
        ["args"] = "[args]",
        ["kwargs"] = "[kwargs]",
    },
})

vim.keymap.set("n", "<leader>ng", require("neogen").generate, { silent = true, desc = "neogen" })
