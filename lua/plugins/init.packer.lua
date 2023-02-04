local fn = vim.fn
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    PACKER_BOOTSTRAP = vim.fn.system({
        "git",
        "clone",
        "--depth",
        "1",
        "https://github.com/wbthomason/packer.nvim",
        install_path,
    })
end

vim.cmd([[packadd packer.nvim]])

local _packer, packer = pcall(require, "packer")

if not _packer then
    return
end

packer.init({
    display = {
        open_fn = function()
            return require("packer.util").float({ border = "single" })
        end,
    },
    git = {
        clone_timeout = 600,
    },
})

return packer.startup(function(use)
    use({ "wbthomason/packer.nvim" })
    use({
        "kyazdani42/nvim-web-devicons",
        config = function()
            require("plugins.configs.icons")
        end,
    })
    use({
        "nvim-telescope/telescope.nvim",
        requires = { { "nvim-lua/plenary.nvim" } },
        config = function()
            require("plugins.configs.telescope")
        end,
    })

    use({
        "joshdick/onedark.vim",
        -- config = function()
        --     vim.o.background = "dark"
        --     vim.g.onedark_terminal_italics = 1
        -- end,
    })
    use({ "mhartington/oceanic-next" })
    use({ "tiagovla/tokyodark.nvim" })
    use({
        "catppuccin/nvim",
        as = "catppuccin",
        config = function()
            require("catppuccin").setup({
                flavour = "macchiato", -- mocha, macchiato, frappe, latte
            })
        end,
    })
    use({ "arcticicestudio/nord-vim" })

    use({
        "nvim-lualine/lualine.nvim",
        requires = { "kyazdani42/nvim-web-devicons", opt = true },
        config = function()
            require("plugins.configs.lualine")
        end,
    })
    use({
        "kyazdani42/nvim-tree.lua",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("plugins.configs.nvimtree")
        end,
    })
    use({
        "akinsho/bufferline.nvim",
        tag = "v2.*",
        requires = "kyazdani42/nvim-web-devicons",
        config = function()
            require("plugins.configs.bufferline")
        end,
    })
    use({
        "tiagovla/scope.nvim", -- make bufferline only show buffers of the current tab
        config = function()
            require("scope").setup()
        end,
    })
    use({
        "windwp/nvim-autopairs",
        config = function()
            require("plugins.configs.nvim_autopairs")
        end,
    })
    use({
        "simrat39/symbols-outline.nvim",
        config = function()
            require("plugins.configs.symbols_outline")
        end,
    })
    use({
        "folke/which-key.nvim",
        config = function()
            require("plugins.configs.which_key")
        end,
    })
    use({
        "nvim-treesitter/nvim-treesitter",
        run = ":TSUpdate",
        config = function()
            require("plugins.configs.nvim_treesitter")
        end,
    })
    use({
        "p00f/nvim-ts-rainbow",
    })
    use({
        "lukas-reineke/indent-blankline.nvim",
        config = function()
            require("plugins.configs.intentline")
        end,
    })
    use({
        "mhinz/vim-startify",
        config = function()
            require("plugins.configs.startify")
        end,
    })
    use({
        "iamcco/markdown-preview.nvim",
        run = function()
            vim.fn["mkdp#util#install"]()
        end,
    })
    use({
        "numToStr/Comment.nvim",
        config = function()
            require("plugins.configs.comment")
        end,
    })
    use({
        "ethanholz/nvim-lastplace",
        config = function()
            require("plugins.configs.nvim_lastplace")
        end,
    })
    use({
        "norcalli/nvim-colorizer.lua",
        config = function()
            require("colorizer").setup()
        end,
    })
    use({
        "lewis6991/gitsigns.nvim",
        config = function()
            require("plugins.configs.gitsigns")
        end,
    })
    use({
        "rmagatti/auto-session",
        config = function()
            require("plugins.configs.auto_session")
        end,
    })
    use({
        "rmagatti/session-lens",
        config = function()
            require("session-lens").setup()
        end,
    })
    use({
        "Pocco81/auto-save.nvim",
        config = function()
            require("plugins.configs.autosave")
        end,
    })

    use({
        "mbbill/undotree",
        config = function()
            require("plugins.configs.undotree")
        end,
    })
    use({
        "gelguy/wilder.nvim",
        config = function()
            require("plugins.configs.wilder")
        end,
    })
    -- use({
    --     "nvim-neorg/neorg",
    --     config = function()
    --         require("plugins.configs.neorg")
    --     end,
    -- })
    use({
        "preservim/vim-markdown",
    })
    -- use({
    --     "anuvyklack/nvim-keymap-amend",
    -- })
    use({
        "rcarriga/nvim-notify",
        config = function()
            require("plugins.configs.nvim_notify")
        end,
    })
    -- use({
    --     "alfredodeza/pytest.vim",
    -- })
    use({
        "akinsho/toggleterm.nvim",
        tab = "v1.*",
        config = function()
            require("plugins.configs.toggleterm")
        end,
    })
    use({
        "voldikss/vim-floaterm",
    })
    use({
        "kevinhwang91/nvim-ufo",
        requires = "kevinhwang91/promise-async",
        config = function()
            require("plugins.configs.nvim_ufo")
        end,
    })
    use({
        "anuvyklack/pretty-fold.nvim",
        config = function()
            require("plugins.configs.pretty_fold")
        end,
    })
    use({
        "junegunn/vim-easy-align",
    })
    use({
        "psliwka/vim-smoothie",
    })
    use({
        "machakann/vim-sandwich",
        config = function()
            require("plugins.configs.sandwich")
        end,
    })
    -- lsp
    use({
        "neovim/nvim-lspconfig",
        config = function()
            require("plugins.configs.nvim_lspconfig")
        end,
    })
    -- completion
    use({ "hrsh7th/cmp-nvim-lsp" })
    use({ "hrsh7th/cmp-nvim-lua" })
    use({ "hrsh7th/cmp-buffer" })
    use({ "hrsh7th/cmp-path" })
    -- use { 'hrsh7th/cmp-cmdline' }
    use({
        "L3MON4D3/LuaSnip",
        config = function()
            require("plugins.configs.luasnip")
        end,
    })
    use({ "saadparwaiz1/cmp_luasnip" })
    use({
        "hrsh7th/nvim-cmp",
        config = function()
            require("plugins.configs.nvim_cmp")
        end,
    })
    -- use { 'onsails/lspkind.nvim' }
    use({
        "williamboman/mason.nvim",
        config = function()
            require("plugins.configs.mason")
        end,
    })
    use({ "williamboman/mason-lspconfig.nvim" })
    use({
        "glepnir/lspsaga.nvim",
        branch = "main",
        config = function()
            require("plugins.configs.lspsaga")
        end,
    })
    use({
        "jose-elias-alvarez/null-ls.nvim",
        config = function()
            require("plugins.configs.null_ls")
        end,
    })
    use({
        "mhartington/formatter.nvim",
        config = function()
            require("plugins.configs.formatter")
        end,
    })
    use({
        "ray-x/lsp_signature.nvim",
        config = function()
            require("plugins.configs.lsp_signature")
        end,
    })
    use({
        "SmiteshP/nvim-navic",
        requires = "neovim/nvim-lspconfig",
        config = function()
            require("plugins.configs.nvim_navic")
        end,
    })
    -- need install im-select, homepage: https://github.com/daipeihust/im-select
    -- brew tap daipeihust/tap && brew install im-select
    use({
        "vim-test/vim-test",
        config = function()
            require("plugins.configs.vim_test")
        end,
    })
    use({
        "CRAG666/code_runner.nvim",
        requires = "nvim-lua/plenary.nvim",
        config = function()
            require("plugins.configs.code_runner")
        end,
    })
    use({
        "stevearc/dressing.nvim",
        config = function()
            require("plugins.configs.dressing")
        end,
    })
    use({
        "folke/noice.nvim",
        requires = {
            -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
            "MunifTanjim/nui.nvim",
            -- OPTIONAL:
            --   `nvim-notify` is only needed, if you want to use the notification view.
            --   If not available, we use `mini` as the fallback
            "rcarriga/nvim-notify",
        },
        config = function()
            require("plugins.configs.noice")
        end,
    })
    use({ "~/Developer/myfirstplugin" })
    use({
        -- highlight cursor word
        "nyngwang/murmur.lua",
        config = function()
            require("murmur").setup({})
        end,
    })

    if PACKER_BOOTSTRAP then
        require("packer").sync()
    end
end)
