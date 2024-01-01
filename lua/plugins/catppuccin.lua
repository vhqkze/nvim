---@diagnostic disable:unused-local

require("catppuccin").setup({
    flavour = "macchiato",
    highlight_overrides = {
        all = function(colors)
            return {
                Visual = { bg = "#3e4452" },
            }
        end,
        macchiato = function(colors)
            return {
                Visual = { bg = "#3e4452" },
                IncSearch = { fg = "#1e2030", bg = "#ff9e64" },
                CurSearch = { fg = "#1e2030", bg = "#ff9e64" },
                FlashLabel = { fg = "#c0caf5", bg = "#ff007c", bold = true },
            }
        end,
    },
    styles = {
        functions = { "italic" },
    },
    integrations = {
        barbecue = {
            alt_background = false,
        },
    },
})
