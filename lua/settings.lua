vim.opt.number = true -- 显示行号
vim.opt.numberwidth = 1 -- 行号宽度
vim.opt.cursorline = true -- 高亮当前行

vim.opt.smartindent = true -- 智能缩进
vim.opt.expandtab = true -- 输入tab自动转为空格
vim.opt.tabstop = 4 -- 设置tab字符显示宽度
vim.opt.softtabstop = 4 -- tab转为多少个空格
vim.opt.shiftwidth = 4 -- 自动缩进时，缩进长度为4

vim.opt.mouse = "a" -- 支持使用鼠标
-- vim.opt.encoding = "utf-8" -- 使用utf-8编码
-- vim.opt.fileformat = "unix"
vim.opt.laststatus = 2 -- 状态栏始终显示
vim.opt.scrolloff = 3 -- 上下显示多余3行
vim.opt.sidescrolloff = 20 -- 水平滚动时预留字符数

vim.opt.ignorecase = true -- 搜索时忽略大小写
vim.opt.smartcase = true -- 如果有一个大写字母，则切换到大小写敏感查找
-- vim.opt.hlsearch = true -- 高亮搜索结果，所有结果都高亮显示，而不是只显示一个匹配
-- vim.opt.incsearch = true -- 逐步搜索模式，对当前键入的字符进行搜索而不必等待键入完成
vim.opt.wrapscan = true -- 重新搜索，在搜索到文件头或尾时，返回继续搜索，默认开启
-- vim.opt.backspace = "indent,eol,start" -- backspace works on every char in insert mode
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.cmdheight = 0
vim.opt.whichwrap:append("hl[]") -- 让h、l键在行首、行尾时可以进入上一行、下一行

vim.opt.clipboard:append("unnamedplus")

-- provider
if vim.fn.has("mac") == 1 then
    vim.g.python3_host_prog = "/usr/local/bin/python3"
elseif vim.fn.has("linux") == 1 then
    vim.g.python3_host_prog = "/usr/bin/python3"
end
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

vim.opt.showmode = false
vim.opt.laststatus = 3
vim.opt.list = false

vim.opt.termguicolors = true
vim.opt.signcolumn = "auto:3"
vim.opt.splitbelow = true
vim.opt.splitright = true
if vim.fn.has("nvim-0.9.0") == 1 then
    vim.opt.splitkeep = "topline"
end

vim.opt.fillchars:append({
    horiz     = "─",
    horizup   = "┴",
    horizdown = "┬",
    vert      = "│",
    vertleft  = "┤",
    vertright = "├",
    verthoriz = "┼",

    fold      = " ",
    foldopen  = "",
    foldclose = "",
    foldsep   = " ",

    diff      = " ",
    eob       = " ",
    lastline  = ".",
})
vim.opt.listchars:append({
    tab = ">-",
    space = "·",
    trail = "·",
})

vim.filetype.add({
    extension = {
        ---@diagnostic disable-next-line: unused-local
        bak = function(path, bufnr)
            return vim.filetype.match({ filename = path:gsub("%.bak$", "") })
        end,
        log = "log",
    },
})
