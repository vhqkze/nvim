local silicon = require("silicon")
silicon.setup({
    output = os.getenv("HOME") .. "/Pictures/Screenshots/SILICON_$year$month$date_$time.png",
    theme = "auto",
    debug = false,
    font = "Sarasa Term SC; Symbols Nerd Font; Iosevka; codicon",
    bgColor = "#ffffff00",
    windowControls = false,
    shadowColor = "#000000",
    shadowBlurRadius = 15,
    padHoriz = 36,
    padVert = 36,
    shadowOffsetX = 0,
    shadowOffsetY = 0,
})

-- Generate image of lines in a visual selection
vim.keymap.set({ "n", "x" }, "<Leader>ps", function()
    silicon.visualise_api({ to_clip = true })
end, { silent = true, desc = "对当前行或选中行截图" })
-- Generate image of a whole buffer, with lines in a visual selection highlighted
vim.keymap.set("x", "<Leader>pp", function()
    silicon.visualise_api({ to_clip = true, show_buf = true })
end, { silent = true, desc = "整体截图，高亮已选择的行" })
vim.keymap.set("n", "<leader>pp", function()
    vim.cmd("normal mpggVG")
    silicon.visualise_api({ to_clip = true })
    local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
    vim.api.nvim_feedkeys(esc, "x", false)
    vim.cmd("normal `p")
end, { silent = true, desc = "整体截图" })
-- Generate visible portion of a buffer
vim.keymap.set("n", "<Leader>pv", function()
    silicon.visualise_api({ to_clip = true, visible = true })
end, { silent = true, desc = "对当前可视范围截图" })

-- builds a new tmTheme file from current colorscheme
-- lua require("silicon.utils").build_tmTheme()
