local navbuddy = require("nvim-navbuddy")
local utils = require("utils")

navbuddy.setup({
    node_markers = {
        icons = {
            leaf = " ",
            leaf_selected = " ",
            branch = " ",
        },
    },
    -- stylua: ignore
    icons = {
        File          = " ",
        Module        = " ",
        Namespace     = " ",
        Package       = " ",
        Class         = " ",
        Method        = " ",
        Property      = " ",
        Field         = " ",
        Constructor   = " ",
        Enum          = " ",
        Interface     = " ",
        Function      = " ",
        Variable      = " ",
        Constant      = " ",
        String        = " ",
        Number        = " ",
        Boolean       = " ",
        Array         = " ",
        Object        = " ",
        Key           = " ",
        Null          = " ",
        EnumMember    = " ",
        Struct        = " ",
        Event         = " ",
        Operator      = " ",
        TypeParameter = " ",
    },
})

-- stylua: ignore
local hls = {
    File          = "@text.uri",
    Module        = "@namespace",
    Namespace     = "@namespace",
    Package       = "@namespace",
    Class         = "@type",
    Method        = "@method",
    Property      = "@method",
    Field         = "@field",
    Constructor   = "@constructor",
    Enum          = "@type",
    Interface     = "@type",
    Function      = "@function",
    Variable      = "@constant",
    Constant      = "@constant",
    String        = "@string",
    Number        = "@number",
    Boolean       = "@boolean",
    Array         = "@constant",
    Object        = "@type",
    Key           = "@type",
    Null          = "@type",
    EnumMember    = "@field",
    Struct        = "@type",
    Event         = "@type",
    Operator      = "@operator",
    TypeParameter = "@parameter",
}

local function update_navbuddy_color()
    for t, d in pairs(hls) do
        local color = utils.get_hl(d, "fg#")
        if color ~= nil and color ~= "" then
            vim.cmd("hi Navbuddy" .. t .. " guifg=" .. color)
        end
    end
    vim.cmd("hi NavbuddyCursorLine cterm=bold,reverse gui=bold,reverse")

    local bg_color = utils.get_hl("normal", "bg#")
    bg_color = bg_color == "" and "NONE" or bg_color
    vim.cmd("hi NavbuddyNormalFloat guibg=" .. bg_color)
    vim.cmd("hi NavbuddyFloatBorder guibg=" .. bg_color)
end

update_navbuddy_color()
vim.api.nvim_create_autocmd("ColorScheme", { callback = update_navbuddy_color })

vim.keymap.set("n", "<leader>nb", navbuddy.open, { silent = true, desc = "Navbuddy" })
