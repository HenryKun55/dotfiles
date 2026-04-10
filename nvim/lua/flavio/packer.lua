vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  -- LSP: mason + mason-lspconfig + lsp-zero
  use {
    'williamboman/mason.nvim',
    config = function()
      require("mason").setup()
    end
  }

  use {
    'williamboman/mason-lspconfig.nvim',
    after = 'mason.nvim',
    config = function()
      require("mason-lspconfig").setup({
        automatic_installation = true,
      })
    end
  }

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v1.x',
    requires = {
      -- LSP support
      { 'neovim/nvim-lspconfig' },

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-vsnip' },
      { 'hrsh7th/vim-vsnip' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'hrsh7th/cmp-nvim-lua' },

      -- Snippets
      {
        "L3MON4D3/LuaSnip",
        tag = "v2.*",
        run = "make install_jsregexp"
      },
      { 'rafamadriz/friendly-snippets' },
    }
  }

  -- Syntax & Treesitter
  use 'windwp/nvim-ts-autotag'
  use({ 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' })

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
  }
  use 'nvim-telescope/telescope-ui-select.nvim'
  use 'nvim-telescope/telescope-file-browser.nvim'

  -- UI / Usabilidade
  use {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
  }
  use 'christoomey/vim-tmux-navigator'
  use 'wuelnerdotexe/vim-astro'
  use "princejoogie/tailwind-highlight.nvim"
  use 'kdheepak/lazygit.nvim'

  -- Git
  use {
    'lewis6991/gitsigns.nvim',
    commit = "929183666540e164fa74028954ade62fa703fa1a"
  }

  use {
    'akinsho/git-conflict.nvim',
    tag = "*",
    config = function()
      require('git-conflict').setup()
    end
  }

  -- Extras
  use 'AndrewRadev/tagalong.vim'

  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  }

  use {
    'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup()
    end
  }

  use {
    'ThePrimeagen/harpoon',
    config = function()
      require("harpoon").setup({
        menu = {
          width = vim.api.nvim_win_get_width(0) - 40,
        }
      })
    end
  }

  use {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup {}
    end
  }

  -- Formatter
  use 'MunifTanjim/prettier.nvim'

  --[[
  use {
    "m4xshen/hardtime.nvim",
    requires = { "MunifTanjim/nui.nvim" },
    config = function()
      require("hardtime").setup()
    end
  }
  --]]

  use {
    'nvim-flutter/flutter-tools.nvim',
    requires = {
      'nvim-lua/plenary.nvim',
    },
  }
end)
