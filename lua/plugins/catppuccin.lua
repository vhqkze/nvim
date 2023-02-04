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
            }
        end,
    },
})
