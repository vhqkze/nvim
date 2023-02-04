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
        File          = { icon = " ", hl = "TSURI"         },
        Module        = { icon = " ", hl = "TSNamespace"   },
        Namespace     = { icon = " ", hl = "TSNamespace"   },
        Package       = { icon = " ", hl = "TSNamespace"   },
        Class         = { icon = " ", hl = "TSType"        },
        Method        = { icon = " ", hl = "TSMethod"      },
        Property      = { icon = " ", hl = "TSMethod"      },
        Field         = { icon = " ", hl = "TSField"       },
        Constructor   = { icon = " ", hl = "TSConstructor" },
        Enum          = { icon = " ", hl = "TSType"        },
        Interface     = { icon = " ", hl = "TSType"        },
        Function      = { icon = " ", hl = "TSFunction"    },
        Variable      = { icon = " ", hl = "TSConstant"    },
        Constant      = { icon = " ", hl = "TSConstant"    },
        String        = { icon = " ", hl = "TSString"      },
        Number        = { icon = " ", hl = "TSNumber"      },
        Boolean       = { icon = " ", hl = "TSBoolean"     },
        Array         = { icon = " ", hl = "TSConstant"    },
        Object        = { icon = " ", hl = "TSType"        },
        Key           = { icon = " ", hl = "TSType"        },
        Null          = { icon = " ", hl = "TSType"        },
        EnumMember    = { icon = " ", hl = "TSField"       },
        Struct        = { icon = " ", hl = "TSType"        },
        Event         = { icon = " ", hl = "TSType"        },
        Operator      = { icon = " ", hl = "TSOperator"    },
        TypeParameter = { icon = " ", hl = "TSParameter"   },
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
