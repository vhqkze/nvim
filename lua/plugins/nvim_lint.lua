local lint = require("lint")

lint.linters.commitlint.env = { NODE_PATH = vim.fn.stdpath("data") .. "/mason/packages/commitlint/node_modules" }

require("lint").linters_by_ft = {
    markdown = { "markdownlint" },
    gitcommit = { "commitlint" },
}

vim.api.nvim_create_autocmd({ "BufRead", "TextChanged", "BufWritePost", "InsertLeave" }, {
    callback = function()
        if vim.bo.modifiable then
            lint.try_lint()
        end
        local filepath = vim.api.nvim_buf_get_name(0)
        if filepath:match(".*/%.github/workflows/.*%.ya?ml") then
            lint.try_lint("actionlint")
        end
    end,
})
