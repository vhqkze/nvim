vim.opt.number = true -- 显示行号
vim.opt.numberwidth = 1 -- 行号宽度
vim.opt.cursorline = true -- 高亮当前行

vim.opt.smartindent = false -- 智能缩进
vim.opt.expandtab = true -- 输入tab自动转为空格
vim.opt.tabstop = 4 -- 设置tab字符显示宽度
vim.opt.softtabstop = 4 -- tab转为多少个空格
vim.opt.shiftwidth = 4 -- 自动缩进时，缩进长度为4

vim.opt.mouse = "a" -- 支持使用鼠标
-- vim.opt.encoding = "utf-8" -- 使用utf-8编码
-- vim.opt.fileformat = "unix"
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
vim.opt.whichwrap:append({ h = true, l = true, ["["] = true, ["]"] = true, ["<"] = true, [">"] = true })

vim.opt.clipboard:append("unnamedplus")
vim.opt.shortmess:append("I")
vim.g.health = { style = "float" }

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

-- stylua: ignore
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
vim.opt.diffopt:append({ "vertical", "indent-heuristic", "algorithm:histogram", "context:100000" })
vim.opt.mousescroll = { "ver:1", "hor:2" }
vim.opt.guicursor = {
    "n-v-sm:block-blinkon30",
    "i-c-ci-ve:ver25-blinkon30",
    "r-cr-o:hor20-blinkon30",
}

vim.g.asciidoc_folding = 1
vim.g.asciidoc_fold_under_title = 0
vim.g.asciidoc_fold_under_title = 0

vim.filetype.add({
    extension = {
        ---@diagnostic disable-next-line: unused-local
        bak = function(path, bufnr)
            return vim.filetype.match({ filename = path:gsub("%.bak$", "") })
        end,
        log = "log",
    },
})
