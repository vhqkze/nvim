vim.g.mapleader = ","
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local IS_ME = vim.env.LOGNAME == "vhqkze"

local lazy_config = {
    defaults = {
        lazy = false,
    },
    git = {
        url_format = "https://github.com/%s.git",
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
        colorscheme = { "catppuccin-macchiato", "tokyonight-storm", "onedark", "habamax" },
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
        cond = false,
        priority = 1000,
        config = function()
            vim.g.onedark_terminal_italics = 1
        end,
    },
    {
        "mhartington/oceanic-next",
        cond = false,
        priority = 1000,
        config = function()
            vim.g.oceanic_next_terminal_bold = 1
            vim.g.oceanic_next_terminal_italic = 1
        end,
    },
    {
        "folke/tokyonight.nvim",
        cond = true,
        priority = 1000,
        config = function()
            require("plugins.tokyonight")
        end,
    },
    {
        "catppuccin/nvim",
        cond = false,
        name = "catppuccin",
        priority = 1000,
        config = function()
            require("plugins.catppuccin")
        end,
    },
    {
        "arcticicestudio/nord-vim",
        cond = false,
        priority = 1000,
    },
    {
        "nvim-tree/nvim-web-devicons",
        event = "UiEnter",
        config = function()
            require("plugins.icons")
        end,
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        event = "UiEnter",
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
        version = "*",
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
        "hedyhli/outline.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.symbols_outline")
        end,
    },
    {
        "folke/which-key.nvim",
        event = "UiEnter",
        config = function()
            require("plugins.which_key")
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = "VeryLazy",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
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
        "HiPhish/rainbow-delimiters.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.rainbow_delimiters")
        end,
    },
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        event = "VeryLazy",
        config = function()
            require("plugins.indentline")
        end,
    },
    {
        "nvimdev/dashboard-nvim",
        event = "UiEnter",
        config = function()
            require("plugins.dashboard")
        end,
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
    },
    {
        "iamcco/markdown-preview.nvim",
        ft = { "markdown" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    {
        "NvChad/nvim-colorizer.lua",
        event = "VeryLazy",
        config = function()
            require("colorizer").setup({
                user_default_options = {
                    AARRGGBB = true,
                },
            })
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
        event = "VeryLazy",
        config = function()
            require("plugins.auto_session")
        end,
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
        event = { "BufRead", "VeryLazy" },
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
        "vhyrro/luarocks.nvim",
        -- priority = 1000, -- We'd like this plugin to load first out of the rest
        event = "VeryLazy",
        config = true, -- This automatically runs `require("luarocks-nvim").setup()`
    },
    {
        "nvim-neorg/neorg",
        ft = { "norg" },
        dependencies = { "vhyrro/luarocks.nvim" },
        version = "*",
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
        init = function()
            vim.g.sandwich_no_default_key_mappings = 1
        end,
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
        "nvimdev/lspsaga.nvim",
        event = { "BufRead", "VeryLazy" },
        config = function()
            require("plugins.lspsaga")
        end,
    },
    {
        "mfussenegger/nvim-lint",
        event = { "BufRead", "VeryLazy" },
        config = function()
            require("plugins.nvim_lint")
        end,
    },
    {
        "mhartington/formatter.nvim",
        event = { "BufRead", "VeryLazy" },
        config = function()
            require("plugins.formatter")
        end,
    },
    {
        "ray-x/lsp_signature.nvim",
        event = { "BufRead", "VeryLazy" },
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
    {
        "SmiteshP/nvim-navbuddy",
        lazy = true,
        dependencies = {
            "SmiteshP/nvim-navic",
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("plugins.nvim_navbuddy")
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
            "L3MON4D3/cmp-luasnip-choice",
            "hrsh7th/cmp-cmdline",
            "dmitmel/cmp-cmdline-history",
            "lukas-reineke/cmp-under-comparator",
        },
        event = { "InsertEnter", "CmdlineEnter" },
        config = function()
            require("plugins.nvim_cmp")
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
        event = { "UiEnter", "CmdlineEnter", "VeryLazy" },
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
        config = function()
            require("plugins.noice")
        end,
    },
    {
        "vhqkze/text-radar",
        cond = IS_ME,
        event = "VeryLazy",
        config = true,
    },
    {
        "Exafunction/codeium.nvim",
        event = "InsertEnter",
        config = function()
            require("plugins.codeium")
        end,
    },
    {
        "vhqkze/nvim-switch-ime",
        cond = IS_ME,
        event = "InsertEnter",
        enabled = function()
            return vim.fn.has("mac") == 1
        end,
        config = true,
    },
    {
        "vhqkze/stringman",
        cond = IS_ME,
        event = "VeryLazy",
        config = true,
    },
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        config = function()
            require("plugins.flash")
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
    {
        "nvim-pack/nvim-spectre",
        event = "VeryLazy",
        build = function()
            if vim.fn.executable("cargo") == 0 then
                vim.notify("cargo not found!", vim.log.levels.ERROR, { title = "Spectre" })
                return
            end
            local repodir = vim.fn.fnamemodify(lazypath, ":h") .. "/nvim-spectre"
            vim.system({ "./build.sh" }, { cwd = repodir, text = true }, function(obj)
                if obj.code == 0 then
                    vim.notify("Spectre build success", vim.log.levels.INFO, { title = "Spectre" })
                else
                    local spectre_msg = "Spectre build failed!\n" .. vim.trim(obj.stderr)
                    vim.notify(spectre_msg, vim.log.levels.ERROR, { title = "Spectre" })
                end
            end)
        end,
        config = function()
            require("plugins.spectre")
        end,
    },
    {
        "mcauley-penney/visual-whitespace.nvim",
        event = "VeryLazy",
        config = true,
    },
}, lazy_config)

vim.cmd.colorscheme("tokyonight-storm")
-- vim.cmd.colorscheme("catppuccin-macchiato")
