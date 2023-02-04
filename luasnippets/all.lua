--- @diagnostic disable: unused-local
local ls = require("luasnip")
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local snippets, autosnippets = {}, {}

snippets = {
    postfix(".[", {
        l("[" .. l.POSTFIX_MATCH .. "]"),
    }),
    s({
        trig = "date",
        name = "get current date",
        dscr = "%Y-%m-%d",
    }, extras.partial(os.date, "%Y-%m-%d")),
    s({
        trig = "time",
        name = "get current time",
        dscr = "%H:%M:%S",
    }, extras.partial(os.date, "%H:%M:%S")),
    s({
        trig = "datetime",
        name = "get current datetime",
        dscr = "first snip",
    }, extras.partial(os.date, "%Y-%m-%d %H:%M:%S")),
}

return snippets, autosnippets
