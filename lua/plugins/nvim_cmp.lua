local cmp = require("cmp")
local luasnip = require("luasnip")

local has_words_before = function()
    table.unpack = unpack or table.unpack -- 5.1 compatibility
    local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

vim.opt.completeopt = "menu,menuone,noselect"
vim.opt.complete = ""

local cmp_kinds = {
    Text          = " ",
    Method        = " ",
    Function      = " ",
    Constructor   = " ",
    Field         = " ",
    Variable      = " ",
    Class         = " ",
    Interface     = " ",
    Module        = " ",
    Property      = " ",
    Unit          = " ",
    Value         = " ",
    Enum          = " ",
    Keyword       = " ",
    Snippet       = " ",
    Color         = " ",
    File          = " ",
    Reference     = " ",
    Folder        = " ",
    EnumMember    = " ",
    Constant      = " ",
    Struct        = " ",
    Event         = " ",
    Operator      = " ",
    TypeParameter = " ",
    Codeium       = " ",
}

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end,
    },
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuSel,Search:None,CursorLine:PmenuSel",
            col_offset = -4,
            side_padding = 0,
            scrolloff = 2,
        },
        documentation = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu",
        },
    },
    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            local kind_text = vim_item.kind
            vim_item.kind = string.format(" %s ", cmp_kinds[kind_text])
            local source_names = {
                nvim_lsp        = "[LSP]",
                luasnip         = "[Snippet]",
                nvim_lua        = "[Lua]",
                buffer          = "[Buffer]",
                path            = "[Path]",
                cmdline         = "[cmd]",
                cmdline_history = "[History]",
                codeium         = "[Codeium]",
            }
            -- show lsp client name
            local source_name = ""
            if entry.source.name == "nvim_lsp" then
                source_name = string.format("[%s]", entry.source.source.client.name)
            else
                source_name = source_names[entry.source.name] or string.format("<%s>", entry.source.name)
            end
            vim_item.menu = string.format("%-10s", kind_text) .. "  " .. source_name
            if string.len(vim_item.abbr) > 50 then
                vim_item.abbr = string.sub(vim_item.abbr, 1, 50)
            end
            return vim_item
        end,
    },
    mapping = {
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
            elseif luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
            elseif has_words_before() then
                cmp.complete()
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
                luasnip.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        -- ["<Down>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<Down>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.choice_active() then
                luasnip.change_choice(1)
            else
                fallback()
            end
        end, { "i", "s" }),
        -- ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<C-m>"] = cmp.mapping(function(fallback)
            if not cmp.visible() then
                cmp.complete({
                    config = {
                        sources = {
                            { name = "codeium" },
                        },
                    },
                })
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-n>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif luasnip.choice_active() then
                luasnip.change_choice(1)
            else
                cmp.complete({
                    config = {
                        sources = {
                            { name = "codeium" },
                        },
                    },
                })
            end
        end, { "i", "s" }),
        -- ["<Up>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<Up>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.choice_active() then
                luasnip.change_choice(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        -- ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }), { "i" }),
        ["<C-p>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif luasnip.choice_active() then
                luasnip.change_choice(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        ["<C-u>"] = cmp.mapping.scroll_docs(-4),
        ["<Esc>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.abort()
            else
                fallback()
            end
        end, { "i", "s" }),
    },
    matching = {
        disallow_fuzzy_matching = false,
        disallow_fullfuzzy_matching = false,
        disallow_partial_fuzzy_matching = false,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
        disallow_symbol_nonprefix_matching = false,
    },
    sorting = {
        priority_weight = 1.0,
        comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            require("cmp-under-comparator").under,
            cmp.config.compare.locality,
            cmp.config.compare.kind,
            cmp.config.compare.sort_text,
            cmp.config.compare.length,
            cmp.config.compare.order,
        },
    },
    preselect = cmp.PreselectMode.None,
    sources = cmp.config.sources({
        { name = "luasnip" },
        { name = "codeium" },
        { name = "nvim_lsp" },
        { name = "buffer", option = {
            keyword_length = 3,
        }, max_item_count = 6 },
        { name = "path" },
    }),
})

cmp.setup.filetype({ "lua" }, {
    sources = {
        { name = "luasnip" },
        { name = "codeium" },
        {
            name = "nvim_lsp",
            entry_filter = function(entry, ctx)
                return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
            end,
        },
        { name = "nvim_lua" },
        { name = "path" },
        { name = "buffer" },
    },
})

cmp.setup.filetype({ "markdown" }, {
    sources = {
        { name = "luasnip" },
        { name = "codeium" },
        { name = "path" },
        { name = "buffer" },
    },
})

cmp.setup.filetype({ "norg" }, {
    sources = {
        { name = "luasnip" },
        { name = "codeium" },
        { name = "neorg" },
        { name = "buffer" },
    },
})

-- 不放在setup里面，否则偶尔启动后<cr>的映射会丢，执行 :verbose imap <cr> 会显示找不到映射
vim.keymap.set("i", "<cr>", function()
    if cmp.visible() then
        cmp.confirm({ select = true })
    else
        local ok, npairs = pcall(require, "nvim-autopairs")
        if ok then
            vim.fn.feedkeys(npairs.autopairs_cr(), "n")
        else
            vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<cr>", true, true, true), "n")
        end
    end
end, { silent = true })

local cmdline_mapping = {
    ["<Up>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        elseif luasnip.choice_active() then
            luasnip.change_choice(-1)
        else
            fallback()
        end
    end, { "c" }),
    ["<Down>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_next_item()
        elseif luasnip.choice_active() then
            luasnip.change_choice(1)
        else
            fallback()
        end
    end, { "c" }),
    ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
        elseif has_words_before() then
            cmp.complete()
        else
            fallback()
        end
    end, { "c" }),
}

local cmdline_formatting = {
    fields = { "abbr", "menu" },
    format = function(entry, vim_item)
        local source_names = {
            buffer          = "[Buffer]",
            path            = "[Path]",
            cmdline         = "[cmd]",
            cmdline_history = "[History]",
        }
        local source_name = source_names[entry.source.name]
        source_name = source_name and source_name or "[other]"
        vim_item.menu = source_name
        if string.len(vim_item.abbr) > 50 then
            vim_item.abbr = string.sub(vim_item.abbr, 0, 50)
        end
        return vim_item
    end,
}

-- cmdline setup.
cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmdline_mapping,
    formatting = cmdline_formatting,
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuSel,Search:None,CursorLine:PmenuSel",
            col_offset = -1,
            side_padding = 2,
        },
        documentation = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu",
        },
    },
    sources = {
        { name = "buffer" },
        { name = "cmdline_history", max_item_count = 10 },
    },
})

cmp.setup.cmdline(":", {
    mapping = cmdline_mapping,
    formatting = cmdline_formatting,
    matching = {
        disallow_fuzzy_matching = false,
        disallow_fullfuzzy_matching = false,
        disallow_partial_fuzzy_matching = false,
        disallow_partial_matching = false,
        disallow_prefix_unmatching = false,
    },
    window = {
        completion = {
            winhighlight = "Normal:Pmenu,FloatBorder:PmenuSel,Search:None,CursorLine:PmenuSel",
            col_offset = -1,
            side_padding = 2,
        },
        documentation = {
            winhighlight = "Normal:Pmenu,FloatBorder:Pmenu",
        },
    },
    sources = cmp.config.sources({
        {
            name = "cmdline",
            option = {
                ignore_cmds = { "Man", "!" },
            },
        },
        { name = "path" },
        { name = "cmdline_history", max_item_count = 10 },
    }),
})

local highlight_config = {
    PmenuSel                 = { bg = "#494d64", fg = "NONE"    },
    Pmenu                    = { fg = "#C5CDD9", bg = "#22252A" },

    CmpItemAbbrDeprecated    = { fg = "#7E8294", bg = "NONE",   strikethrough = true },
    CmpItemAbbrMatch         = { fg = "#82AAFF", bg = "NONE",   bold          = true },
    CmpItemAbbrMatchFuzzy    = { fg = "#82AAFF", bg = "NONE",   bold          = true },
    CmpItemMenu              = { fg = "#C792EA", bg = "NONE",   italic        = true },

    CmpItemKindField         = { fg = "#EED8DA", bg = "#B5585F" },
    CmpItemKindProperty      = { fg = "#EED8DA", bg = "#B5585F" },
    CmpItemKindEvent         = { fg = "#EED8DA", bg = "#B5585F" },

    CmpItemKindText          = { fg = "#C3E88D", bg = "#9FBD73" },
    CmpItemKindEnum          = { fg = "#C3E88D", bg = "#9FBD73" },
    CmpItemKindKeyword       = { fg = "#C3E88D", bg = "#9FBD73" },

    CmpItemKindConstant      = { fg = "#FFE082", bg = "#D4BB6C" },
    CmpItemKindConstructor   = { fg = "#FFE082", bg = "#D4BB6C" },
    CmpItemKindReference     = { fg = "#FFE082", bg = "#D4BB6C" },

    CmpItemKindFunction      = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindStruct        = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindClass         = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindModule        = { fg = "#EADFF0", bg = "#A377BF" },
    CmpItemKindOperator      = { fg = "#EADFF0", bg = "#A377BF" },

    CmpItemKindVariable      = { fg = "#C5CDD9", bg = "#7E8294" },
    CmpItemKindFile          = { fg = "#C5CDD9", bg = "#7E8294" },

    CmpItemKindUnit          = { fg = "#F5EBD9", bg = "#D4A959" },
    CmpItemKindSnippet       = { fg = "#F5EBD9", bg = "#D4A959" },
    CmpItemKindFolder        = { fg = "#F5EBD9", bg = "#D4A959" },

    CmpItemKindMethod        = { fg = "#DDE5F5", bg = "#6C8ED4" },
    CmpItemKindValue         = { fg = "#DDE5F5", bg = "#6C8ED4" },
    CmpItemKindEnumMember    = { fg = "#DDE5F5", bg = "#6C8ED4" },

    CmpItemKindInterface     = { fg = "#D8EEEB", bg = "#58B5A8" },
    CmpItemKindColor         = { fg = "#D8EEEB", bg = "#58B5A8" },
    CmpItemKindTypeParameter = { fg = "#D8EEEB", bg = "#58B5A8" },

    CmpItemKindCodeium       = { fg = "#C3E88D", bg = "#9F5EBD" },
}
for key, value in pairs(highlight_config) do
    vim.api.nvim_set_hl(0, key, value)
end
