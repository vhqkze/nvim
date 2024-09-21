local lint = require("lint")

lint.linters.zhlint = {
    cmd = "zhlint",
    stdin = false,
    append_fname = true,
    args = {},
    stream = "both",
    ignore_exitcode = true,
    env = nil,
    parser = function(output)
        local diagnostics = {}
        local pattern = "^[%w%d%.-_/ ]+:(%d+):(%d+) %- (.+)"
        for _, line in ipairs(vim.fn.split(output, "\n")) do
            if line:match(pattern) then
                local _, _, lnum, word_count, message = line:find(pattern)
                local content = vim.fn.getline(tonumber(lnum))
                content = vim.fn.strcharpart(content, 0, tonumber(word_count))
                local col = string.len(content)
                table.insert(diagnostics, {
                    source = "zhlint",
                    lnum = tonumber(lnum) - 1,
                    col = col,
                    message = message,
                    severity = vim.diagnostic.severity.INFO,
                })
            end
        end
        return diagnostics
    end,
}

lint.linters.commitlint.env = { NODE_PATH = vim.fn.stdpath("data") .. "/mason/packages/commitlint/node_modules" }

require("lint").linters_by_ft = {
    markdown = { "zhlint", "markdownlint" },
    gitcommit = { "commitlint" },
}

vim.api.nvim_create_autocmd({ "BufRead", "TextChanged", "BufWritePost", "InsertLeave" }, {
    callback = function()
        if vim.bo.modifiable then
            require("lint").try_lint()
        end
    end,
})
