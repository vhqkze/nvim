require("pretty-fold").setup({
    matchup_patterns = {
        -- ╟─ Start of line ──╭───────╮── "do" ── End of line ─╢
        --                    ╰─ WSP ─╯
        { "^%s*do$", "end" }, -- `do ... end` blocks

        -- ╟─ Start of line ──╭───────╮── "if" ─╢
        --                    ╰─ WSP ─╯
        { "^%s*if", "end" },

        -- ╟─ Start of line ──╭───────╮── "for" ─╢
        --                    ╰─ WSP ─╯
        { "^%s*for", "end" },

        -- ╟─ "function" ──╭───────╮── "(" ─╢
        --                 ╰─ WSP ─╯
        { "function%s*%(", "end" }, -- 'function(' or 'function ('

        { "{", "}" },
        { "%(", ")" }, -- % to escape lua pattern char
        { "%[", "]" }, -- % to escape lua pattern char
    },
})
