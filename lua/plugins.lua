vim.g.mapleader = ","
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://ghproxy.com/https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local lazy_config = {
    defaults = {
        lazy = false,
    },
    git = {
        url_format = "https://ghproxy.com/https://github.com/%s.git",
    },
    checker = {
        -- automatically check for plugin updates
        enabled = false,
        concurrency = nil, ---@type number? set to 1 to check for updates very slowly
        notify = false, -- get a notification when new updates are found
        frequency = 3600, -- check for updates every hour
    },
    diff = {
        cmd = "diffview.nvim",
    },
    ui = {
        border = "rounded",
    },
    dev = {
        path = "~/Developer/nvim-plugins",
        patterns = { "vhqkze" },
    },
    install = {
        colorscheme = { "catppuccin-macchiato", "tokyodark", "onedark", "habamax" },
    },
    performance = {
        rtp = {
            disabled_plugins = {
                "netrwPlugin",
            },
        },
    },
}

require("lazy").setup({
    {
        "joshdick/onedark.vim",
        event = "VimEnter",
        config = function()
            vim.g.onedark_terminal_italics = 1
        end,
    },
    {
        "mhartington/oceanic-next",
        event = "VimEnter",
        config = function()
            vim.g.oceanic_next_terminal_bold = 1
            vim.g.oceanic_next_terminal_italic = 1
        end,
    },
    {
        "tiagovla/tokyodark.nvim",
        event = "VimEnter",
    },
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("plugins.catppuccin")
            vim.cmd.colorscheme("catppuccin-macchiato")
        end,
    },
    {
        "arcticicestudio/nord-vim",
        event = "VimEnter",
    },
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("plugins.icons")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VimEnter",
        config = function()
            require("plugins.lualine")
        end,
    },
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "VeryLazy",
        config = function()
            require("plugins.nvimtree")
        end,
    },
    {
        "akinsho/bufferline.nvim",
        version = "v3.*",
        event = "VeryLazy",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("plugins.bufferline")
        end,
    },
    {
        "tiagovla/scope.nvim", -- make bufferline only show buffers of the current tab
        event = "VeryLazy",
        dependencies = { "akinsho/bufferline.nvim" },
        config = true,
    },
    {
        "windwp/nvim-autopairs",
        event = "VeryLazy",
        config = function()
            require("plugins.nvim_autopairs")
        end,
    },
    {
        "simrat39/symbols-outline.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.symbols_outline")
        end,
    },
    {
        "folke/which-key.nvim",
        config = function()
            require("plugins.which_key")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        commit = "12e95e160d7d45b76a36bca6303dd8447ab77490",
        event = "VeryLazy",
        build = function()
            local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
            ts_update()
        end,
        config = function()
            require("plugins.nvim_treesitter")
        end,
    },
    {
        "m-demare/hlargs.nvim",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "VeryLazy",
        config = function()
            require("plugins.hlargs")
        end,
    },
    {
        "p00f/nvim-ts-rainbow",
        event = "VeryLazy",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.intentline")
        end,
    },
    {
        "mhinz/vim-startify",
        event = "VimEnter",
        config = function()
            require("plugins.startify")
        end,
    },
    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.comment")
        end,
    },
    {
        "ethanholz/nvim-lastplace",
        cond = false,
        config = function()
            require("plugins.nvim_lastplace")
        end,
    },
    {
        "norcalli/nvim-colorizer.lua",
        event = "VeryLazy",
        config = function()
            require("colorizer").setup()
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.gitsigns")
        end,
    },
    {
        "sindrets/diffview.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        config = function()
            require("plugins.diffview")
        end,
    },
    {
        "rmagatti/auto-session",
        event = "VimEnter", -- do not use VeryLazy, otherwise it will not work
        config = function()
            require("plugins.auto_session")
        end,
    },
    {
        "rmagatti/session-lens",
        event = "VeryLazy",
        dependencies = {
            "rmagatti/auto-session",
            "nvim-telescope/telescope.nvim",
        },
        config = true,
    },
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        event = "VeryLazy",
        config = function()
            require("plugins.telescope")
        end,
    },
    {
        "Pocco81/auto-save.nvim",
        event = { "InsertEnter", "TextChanged" },
        config = function()
            require("plugins.autosave")
        end,
    },
    {
        "mbbill/undotree",
        event = "BufRead",
        config = function()
            require("plugins.undotree")
        end,
    },
    {
        "gelguy/wilder.nvim",
        enabled = false,
        event = "VeryLazy",
        build = ":UpdateRemotePlugins",
        config = function()
            require("plugins.wilder")
        end,
    },
    {
        "nvim-neorg/neorg",
        ft = { "norg" },
        dependencies = { "nvim-lua/plenary.nvim" },
        build = ":Neorg sync-parsers",
        config = function()
            require("plugins.neorg")
        end,
    },
    {
        "preservim/vim-markdown",
        ft = "markdown",
        config = function()
            vim.g.vim_markdown_folding_disabled = 1
            vim.g.vim_markdown_emphasis_multiline = 0
        end,
    },
    {
        "rcarriga/nvim-notify",
        lazy = true,
        config = function()
            require("plugins.nvim_notify")
        end,
    },
    {
        "akinsho/toggleterm.nvim",
        event = "VeryLazy",
        version = "*",
        config = function()
            require("plugins.toggleterm")
        end,
    },
    {
        "voldikss/vim-floaterm",
        event = "VeryLazy",
    },
    {
        "kevinhwang91/nvim-ufo",
        dependencies = { "kevinhwang91/promise-async" },
        event = "VeryLazy",
        config = function()
            require("plugins.nvim_ufo")
        end,
    },
    {
        "anuvyklack/pretty-fold.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.pretty_fold")
        end,
    },
    {
        "junegunn/vim-easy-align",
        event = "VeryLazy",
    },
    {
        "psliwka/vim-smoothie",
        event = "VeryLazy",
    },
    {
        "machakann/vim-sandwich",
        event = "VeryLazy",
        dependencies = {
            {
                "nvim-lua/plenary.nvim",
                -- This plugin is not a dependency, I just use it to configure sandwich.
                config = function()
                    vim.g.sandwich_no_default_key_mappings = 1
                end,
            },
        },
        config = function()
            require("plugins.sandwich")
        end,
    },
    -- lsp
    {
        "neovim/nvim-lspconfig",
        event = "VeryLazy",
        config = function()
            require("plugins.nvim_lspconfig")
        end,
    },
    {
        "williamboman/mason.nvim",
        lazy = true,
        config = function()
            require("plugins.mason")
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        lazy = true,
        dependencies = { "williamboman/mason.nvim" },
    },
    {
        "glepnir/lspsaga.nvim",
        event = "BufRead",
        config = function()
            require("plugins.lspsaga")
        end,
    },
    {
        "jose-elias-alvarez/null-ls.nvim",
        event = "BufRead",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("plugins.null_ls")
        end,
    },
    {
        "mhartington/formatter.nvim",
        event = "BufRead",
        config = function()
            require("plugins.formatter")
        end,
    },
    {
        "ray-x/lsp_signature.nvim",
        event = "BufRead",
        config = function()
            require("plugins.lsp_signature")
        end,
    },
    {
        "SmiteshP/nvim-navic",
        event = "BufRead",
        dependencies = { "neovim/nvim-lspconfig" },
        config = function()
            require("plugins.nvim_navic")
        end,
    },
    {
        "utilyre/barbecue.nvim",
        name = "barbecue",
        version = "*",
        dependencies = {
            "SmiteshP/nvim-navic",
            "nvim-tree/nvim-web-devicons", -- optional dependency
        },
        event = "VeryLazy",
        config = function()
            require("plugins.barbecue")
        end,
    },
    -- completion
    {
        "L3MON4D3/LuaSnip",
        event = "InsertEnter",
        config = function()
            require("plugins.luasnip")
        end,
    },
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-nvim-lua",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "saadparwaiz1/cmp_luasnip",
            "doxnit/cmp-luasnip-choice",
            "hrsh7th/cmp-cmdline",
            "dmitmel/cmp-cmdline-history",
        },
        event = { "InsertEnter", "CmdlineEnter" },
        config = function()
            require("plugins.nvim_cmp")
        end,
    },
    {
        "vim-test/vim-test",
        event = "VeryLazy",
        config = function()
            require("plugins.vim_test")
        end,
    },
    {
        "CRAG666/code_runner.nvim",
        event = "BufRead",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("plugins.code_runner")
        end,
    },
    {
        "stevearc/dressing.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.dressing")
        end,
    },
    {
        "folke/noice.nvim",
        event = "CmdlineEnter",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("plugins.noice")
        end,
    },
    {
        -- highlight cursor word
        "nyngwang/murmur.lua",
        event = "VeryLazy",
        config = function()
            require("plugins.murmur")
        end,
    },
    {
        "ojroques/nvim-osc52",
        cond = function()
            return vim.fn.has("linux") == 1
        end,
        config = function()
            require("plugins.osc52")
        end,
    },
    {
        "narutoxy/silicon.lua",
        cond = function()
            return vim.fn.has("mac") == 1
        end,
        event = "VeryLazy",
        config = function()
            require("plugins.silicon")
        end,
    },
    {
        "jcdickinson/codeium.nvim",
        event = "InsertEnter",
        config = function()
            require("plugins.codeium")
        end,
    },
    {
        "vhqkze/nvim-switch-ime",
        dev = true,
        event = "InsertEnter",
        enabled = function()
            return vim.fn.has("mac") == 1
        end,
        config = true,
    },
    {
        "vhqkze/stringman",
        dev = true,
        event = "VeryLazy",
        config = true,
    },
    {
        "ggandor/leap.nvim",
        event = "VimEnter", -- do not use VeryLazy, otherwise it will not work
        config = function()
            require("plugins.leap")
        end,
    },
    {
        "danymat/neogen",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        event = "VeryLazy",
        config = function()
            require("plugins.neogen")
        end,
    },
    {
        "Vimjas/vim-python-pep8-indent",
        ft = { "python" },
    },
}, lazy_config)
