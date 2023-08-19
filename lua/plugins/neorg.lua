require("neorg").setup({
    load = {
        ["core.defaults"] = {},
        ["core.concealer"] = {
            config = {
                icon_preset = "basic",
                icons = {
                    heading = {
                        -- icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
                        -- icons = {"󰻃 ", "󰺕 ", "󰗝 ", "󱔛 ", "󰦤 ", "󱨧 "},
                        icons = { "󰐾 ", "󰺕 ", "󰄻 ", "󰝨 ", "󰯊 ", "󰥺 " },
                        --    󰝦 󰽤 󰤂     󰴲  󰞯
                        -- 󰪥   󰐾  󰀚 󰻃 󰗮 󰋷 󰹻 󰀘 
                        -- 󰊱 󱡝 󱡞 󰮍 󰮎 󰫤 󰫥 󰊲 󰄻 󱇯 󰘯  󰛡 󱃲 󰗣 󰲉 󰐼 󰵉 󰚯 
                        -- 󱔛 󰡾 󱇢 󱠋 󰴈 󰠖 󰞾 󰺖 󰝨 󰮐 󰮴   󰸳 󰊖 󰸿  󰫢 󰫣 󱍿 󰈐 󰫕 󰫖
                        --    󰓏 󰦤 󱞈 󰟞 󰒸 󰳗
                        --   󰓒  󰓎  󱙧 󰦥 󰜀 󰯊
                        --   󱄅 󰫉 󰫊 󰋸 󰡷 󰥺 󰖙   
                        -- 󰜈   󱀤   󰎂
                        --   󱨧 󰫈 󰋘  󰋙 󰛸 󰜫 󰱺 
                        --  󰜡 󰛄 󰟼  󰖨 󰼪 󰃠
                        --  󰽚 󱥔 󰡂 󰏄  󰂸 󰃞  󰝭 󱢖 󱪂 󰥋 󰺕 󰗝 󱔝
                    },
                    todo = {
                        cancelled = {
                            icon = "󰗨",
                        },
                        done = {
                            icon = "󰄬",
                        },
                        on_hold = {
                            icon = "󰏤",
                        },
                        pending = {
                            icon = "",
                        },
                        recurring = {
                            icon = "󱞳",
                        },
                        uncertain = {
                            icon = "?",
                        },
                        undone = {
                            icon = "×",
                        },
                        urgent = {
                            icon = "!",
                        },
                    },
                },
            },
        },
        ["core.completion"] = {
            config = {
                engine = "nvim-cmp",
            },
        },
        ["core.keybinds"] = {
            config = {
                default_keybinds = true,
                neorg_leader = "<Leader>",
            },
        },
        ["core.journal"] = {
            config = {
                journal_folder = "diary",
            },
        },
        ["core.dirman"] = {
            config = {
                use_popup = false,
                workspaces = {
                    default = "~/Developer/notes/neorg",
                },
            },
        },
    },
})
