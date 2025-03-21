local navbuddy = require("nvim-navbuddy")

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

local utils = require("utils")

for t, d in pairs(hls) do
    local color = utils.get_hl(d, "fg#")
    if color ~= nil and color ~= "" then
        vim.cmd("hi Navbuddy" .. t .. " guifg=" .. color)
    end
end

vim.cmd("hi NavbuddyNormalFloat guibg=" .. utils.get_hl("normal", "bg#"))
vim.cmd("hi NavbuddyFloatBorder guibg=" .. utils.get_hl("normal", "bg#"))

vim.keymap.set("n", "<leader>nb", navbuddy.open, { silent = true, desc = "Navbuddy" })
