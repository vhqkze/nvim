local web_devicons = require("nvim-web-devicons")
web_devicons.setup({
    default = true,
    override = {
        markdown = { icon = "", color = "#ffffff", name = "Markdown" },
        norg = { icon = "", color = "#eab16d", name = "Neorg" },
        http = { icon = "", color = "#e53935", name = "Http" },
        rest = { icon = "", color = "#e53935", name = "Http" },
        ahk = { icon = "", color = "#4caf50", name = "Autohotkey" },
        log = { icon = "󱂅", color = "#4caf50", name = "Log" },
        icns = { icon = "", color = "#a074c4", name = "Icns" },
        adoc = { icon = "󰈙", color = "#6d8086", name = "Asciidoc" },
    },
    override_by_filename = {
        sketchybarrc = { icon = "", color = "#6d8086", name = "Sketchybarrc" },
        yabairc = { icon = "", color = "#6d8086", name = "Yabairc" },
        skhdrc = { icon = "", color = "#6d8086", name = "Skhdrc" },
    },
})
web_devicons.set_default_icon("", "#51a0cf")
