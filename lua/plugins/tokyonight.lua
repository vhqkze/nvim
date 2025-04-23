require("tokyonight").setup({
    style = "storm",
    styles = {
        functions = { italic = true },
    },
    sidebars = { "qf" },
    on_highlights = function(hl, c)
        local CursorLineBg = hl.CursorLine.bg
        hl.GitSignsAddCul = { fg = hl.GitSignsAdd.fg, bg = CursorLineBg }
        hl.GitSignsChangeCul = { fg = hl.GitSignsChange.fg, bg = CursorLineBg }
        hl.GitSignsDeleteCul = { fg = hl.GitSignsDelete.fg, bg = CursorLineBg }
        hl.GitSignsChangedeleteCul = { fg = hl.GitSignsChangedelete and hl.GitSignsChangedelete.fg or hl.GitSignsChange.fg, bg = CursorLineBg }
        hl.GitSignsTopdeleteCul = { fg = hl.GitSignsTopdelete and hl.GitSignsTopdelete.fg or hl.GitSignsDelete.fg, bg = CursorLineBg }
        hl.GitSignsUntrackedCul = { fg = hl.GitSignsUntracked and hl.GitSignsUntracked.fg or hl.GitSignsAdd.fg, bg = CursorLineBg }
        hl.CursorLineNr.bg = CursorLineBg
        hl.CursorLineFold = { bg = CursorLineBg }
        hl.CursorLineSign = { bg = CursorLineBg }
    end,
})
