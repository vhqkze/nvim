local null_ls = require("null-ls")
local helpers = require("null-ls.helpers")

null_ls.setup({
    debug = false,
    sources = {
        null_ls.builtins.diagnostics.commitlint,
        null_ls.builtins.diagnostics.markdownlint,
    },
})

local markdown_completion = {
    method = null_ls.methods.COMPLETION,
    filetypes = { "markdown" },
    name = "nuls",
    generator = {
        fn = function()
            return {
                {
                    items = { { label = "- [ ]", insertText = "- [ ] ", documentation = "todo: undo" } },
                    isIncomplete = true,
                },
                {
                    items = { { label = "- [x]", insertText = "- [x] ", documentation = "todo: done" } },
                    isIncomplete = false,
                },
            }
        end,
    },
}

null_ls.register(markdown_completion)
