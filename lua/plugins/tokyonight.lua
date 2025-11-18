require("tokyonight").setup({
    style = "storm",
    light_style = "storm",
    styles = {
        functions = { italic = true },
    },
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
        hl.BufferLineIndicatorSelected = { fg = hl.TabLineSel.fg, bg = hl.Normal.bg }
        hl.DiagnosticUnnecessary = {}

        -- cmp
        hl.CmpItemAbbrDeprecated = { fg = c.comment, bg = c.none, strikethrough = true }
        hl.CmpItemAbbrMatch = { fg = c.blue, bg = c.none, bold = true }
        hl.CmpItemAbbrMatchFuzzy = { fg = c.blue, bg = c.none, bold = true }
        hl.CmpItemMenu = { fg = c.magenta, bg = c.none, italic = true }

        hl.CmpItemKindField = { fg = c.dark3, bg = c.magenta }
        hl.CmpItemKindProperty = { fg = c.dark3, bg = c.magenta }
        hl.CmpItemKindEvent = { fg = c.dark3, bg = c.magenta }

        hl.CmpItemKindText = { fg = c.dark3, bg = c.green1 }
        hl.CmpItemKindEnum = { fg = c.dark3, bg = c.green1 }
        hl.CmpItemKindKeyword = { fg = c.dark3, bg = c.green1 }
        hl.CmpItemKindVariable = { fg = c.dark3, bg = c.green1 }

        hl.CmpItemKindConstant = { fg = c.dark3, bg = c.yellow }
        hl.CmpItemKindConstructor = { fg = c.dark3, bg = c.yellow }
        hl.CmpItemKindReference = { fg = c.dark3, bg = c.yellow }

        hl.CmpItemKindFunction = { fg = c.fg, bg = c.purple }
        hl.CmpItemKindStruct = { fg = c.fg, bg = c.purple }
        hl.CmpItemKindClass = { fg = c.fg, bg = c.purple }
        hl.CmpItemKindModule = { fg = c.fg, bg = c.purple }
        hl.CmpItemKindOperator = { fg = c.fg, bg = c.purple }

        hl.CmpItemKindUnit = { fg = c.dark3, bg = c.orange }
        hl.CmpItemKindSnippet = { fg = c.dark3, bg = c.orange }
        hl.CmpItemKindFolder = { fg = c.dark3, bg = c.orange }
        hl.CmpItemKindFile = { fg = c.dark3, bg = c.orange }

        hl.CmpItemKindMethod = { fg = c.fg, bg = c.blue }
        hl.CmpItemKindValue = { fg = c.fg, bg = c.blue }
        hl.CmpItemKindEnumMember = { fg = c.fg, bg = c.blue }

        hl.CmpItemKindInterface = { fg = c.fg, bg = c.blue1 }
        hl.CmpItemKindColor = { fg = c.fg, bg = c.blue1 }
        hl.CmpItemKindTypeParameter = { fg = c.fg, bg = c.blue1 }

        hl.CmpItemKindCodeium = { fg = c.dark3, bg = c.cyan }
    end,
})

require("tokyonight").styles = { dark = "storm", light = "storm" }
