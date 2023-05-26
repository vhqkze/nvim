local web_devicons = require("nvim-web-devicons")
local my_icons = {
    norg = { icon = "",  color = "#4caf50", name = "neorg"      },
    md   = { icon = "",  color = "#ea7130", name = "markdown"   },
    http = { icon = "",  color = "#e53935", name = "http"       },
    ahk  = { icon = "",  color = "#4caf50", name = "autohotkey" },
}
if web_devicons.has_loaded() then
    web_devicons.set_icon(my_icons)
else
    web_devicons.setup({ override = my_icons, color_icons = true, default = true })
end

web_devicons.set_default_icon("", "#51a0cf")
