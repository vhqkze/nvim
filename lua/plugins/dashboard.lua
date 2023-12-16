local function get_date()
    local weekdays = { "日", "一", "二", "三", "四", "五", "六" }
    local weekday = weekdays[os.date("%w") + 1]
    return "周" .. weekday .. os.date(" %Y-%m-%d %H:%M")
end

local header = [[

████    ██  ████████   ███████   ██      ██  ████  ███    ███
██ ██   ██  ██        ██     ██  ██      ██   ██   ████  ████
██  ██  ██  ██████    ██     ██   ██    ██    ██   ██ ████ ██
██   ██ ██  ██        ██     ██    ██  ██     ██   ██  ██  ██
██    ████  ████████   ███████      ████     ████  ██      ██
]]

require("dashboard").setup({
    theme = "hyper",
    config = {
        week_header = {
            enable = false,
        },
        shortcut = {
            {
                icon = " ",
                icon_hl = "@function",
                desc = "Edit",
                group = "@property",
                action = function(path)
                    vim.cmd.cd("~")
                    vim.cmd("enew")
                end,
                key = "e",
            },
            {
                icon = " ",
                icon_hl = "@function",
                desc = "Lazy",
                group = "@property",
                action = "Lazy",
                key = "l",
            },
            {
                icon = " ",
                icon_hl = "@function",
                desc = "Session",
                group = "@property",
                action = function()
                    require("auto-session").setup_session_lens()
                    require("auto-session.session-lens").search_session()
                end,
                key = "s",
            },
            {
                icon = "󰗼 ",
                icon_hl = "@function",
                desc = "EXIT",
                group = "@property",
                action = "qa",
                key = "q",
            },
        },
        project = {
            enable = false,
        },
        footer = { "", get_date() },
    },
    preview = {
        command = string.format("echo '%s'", header),
        file_path = "",
        file_height = 6,
        file_width = 61,
    },
})
