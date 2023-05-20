require("symbols-outline").setup({
    wrap = false,
    auto_preview = false,
    lsp_blacklist = {},
    symbol_blacklist = { "Enum", "Variable", "Module" },
    autofold_depth = 1,
    keymaps = {
        hover_symbol = "J",
    },
    symbols = {
        File          = { icon = " ", hl = "@text.uri"    },
        Module        = { icon = " ", hl = "@namespace"   },
        Namespace     = { icon = " ", hl = "@namespace"   },
        Package       = { icon = " ", hl = "@namespace"   },
        Class         = { icon = " ", hl = "@type"        },
        Method        = { icon = " ", hl = "@method"      },
        Property      = { icon = " ", hl = "@method"      },
        Field         = { icon = " ", hl = "@field"       },
        Constructor   = { icon = " ", hl = "@constructor" },
        Enum          = { icon = " ", hl = "@type"        },
        Interface     = { icon = " ", hl = "@type"        },
        Function      = { icon = " ", hl = "@function"    },
        Variable      = { icon = " ", hl = "@constant"    },
        Constant      = { icon = " ", hl = "@constant"    },
        String        = { icon = " ", hl = "@string"      },
        Number        = { icon = " ", hl = "@number"      },
        Boolean       = { icon = " ", hl = "@boolean"     },
        Array         = { icon = " ", hl = "@constant"    },
        Object        = { icon = " ", hl = "@type"        },
        Key           = { icon = " ", hl = "@type"        },
        Null          = { icon = " ", hl = "@type"        },
        EnumMember    = { icon = " ", hl = "@field"       },
        Struct        = { icon = " ", hl = "@type"        },
        Event         = { icon = " ", hl = "@type"        },
        Operator      = { icon = " ", hl = "@operator"    },
        TypeParameter = { icon = " ", hl = "@parameter"   },
        Component     = { icon = " ", hl = "@function"    }, -- TODO: icon
        Fragment      = { icon = " ", hl = "@constant"    }, -- TODO: icon
    },
})

vim.keymap.set({ "n", "i" }, "<M-7>", function()
    local win_ids = vim.api.nvim_list_wins()
    local cur_win_id = vim.api.nvim_get_current_win()
    for _, win_id in pairs(win_ids) do
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        if vim.api.nvim_buf_get_option(buf_id, "filetype") == "Outline" then -- found outline window
            if win_id == cur_win_id then -- right in outline
                return vim.cmd("SymbolsOutlineClose")
            else -- not in outline
                return vim.api.nvim_set_current_win(win_id)
            end
        end
    end
    return vim.cmd("SymbolsOutlineOpen")
end, { silent = true, desc = "Toggle SymbolsOutline" })
