require("code_runner").setup({
    mode = "term",
    focus = false,
    startinsert = false,
    filetype = {
        java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        python = "python3 -u",
        typescript = "deno run",
        rust = "cd $dir && rustc $fileName && $dir/$fileNameWithoutExt",
        go = "go run",
    },
})

vim.keymap.set("n", "<leader>rr", "<cmd>RunClose<cr><cmd>RunCode<cr>", { silent = true, desc = "Run Code" })
vim.keymap.set("n", "<leader>rf", "<cmd>RunClose<cr><cmd>RunFile<cr>", { silent = false, desc = "Run File" })
vim.keymap.set("n", "<leader>rft", "<cmd>RunFile tab<cr>", { silent = false, desc = "Run File Tab" })
vim.keymap.set("n", "<leader>rp", "<cmd>RunProject<cr>", { silent = false, desc = "Run Project" })
vim.keymap.set("n", "<leader>rc", "<cmd>RunClose<cr>", { silent = false, desc = "Run Close" })
vim.keymap.set("n", "<leader>crf", "<cmd>CRFiletype<cr>", { silent = false, desc = "CRFiletype" })
vim.keymap.set("n", "<leader>crp", "<cmd>CRProjects<cr>", { silent = false, desc = "CRProjects" })
