require("lazy").setup({
  -- ============================================================
  -- Colorscheme (eager, alta prioridade)
  -- ============================================================
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
  },

  -- ============================================================
  -- LSP / Mason
  -- ============================================================
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate", "MasonUninstall" },
    config = true,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({ automatic_installation = true })
    end,
  },
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v1.x",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "neovim/nvim-lspconfig" },
  },

  -- tailwind-highlight é carregado on-demand pelo on_attach do tailwindcss LSP (flavio.tailwind)
  {
    "princejoogie/tailwind-highlight.nvim",
    lazy = true,
  },

  -- ============================================================
  -- Completion (carrega quando entra em modo de inserção ou linha de comando)
  -- ============================================================
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lua",
      "saadparwaiz1/cmp_luasnip",
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
      },
    },
    config = function()
      vim.opt.completeopt = { "menu", "menuone" }

      local cmp = require("cmp")
      local has_luasnip, luasnip = pcall(require, "luasnip")

      if has_luasnip then
        pcall(function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end)
      end

      local select_opts = { behavior = cmp.SelectBehavior.Select }

      cmp.setup({
        snippet = {
          expand = function(args)
            if has_luasnip then
              luasnip.lsp_expand(args.body)
            end
          end,
        },
        sources = {
          { name = "path" },
          { name = "nvim_lsp", keyword_length = 1 },
          { name = "buffer",   keyword_length = 3 },
        },
        window = {
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { "menu", "abbr", "kind" },
          format = function(entry, item)
            local menu_icon = {
              nvim_lsp = "λ",
              luasnip = "⋗",
              buffer = "Ω",
              path = "🖫",
            }
            item.menu = menu_icon[entry.source.name]
            return item
          end,
        },
        mapping = {
          ["<Up>"] = cmp.mapping.select_prev_item(select_opts),
          ["<Down>"] = cmp.mapping.select_next_item(select_opts),
          ["<C-p>"] = cmp.mapping.select_prev_item(select_opts),
          ["<C-n>"] = cmp.mapping.select_next_item(select_opts),
          ["<C-u>"] = cmp.mapping.scroll_docs(-4),
          ["<C-d>"] = cmp.mapping.scroll_docs(4),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({ select = true }),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<C-f>"] = cmp.mapping(function(fallback)
            if has_luasnip and luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-b>"] = cmp.mapping(function(fallback)
            if has_luasnip and luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            local col = vim.fn.col(".") - 1
            if cmp.visible() then
              cmp.select_next_item(select_opts)
            elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
              fallback()
            else
              cmp.complete()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item(select_opts)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-Space>"] = cmp.mapping.complete(),
        },
        preselect = cmp.PreselectMode.Item,
        completion = {
          completeopt = "menu,menuone",
        },
      })

      vim.api.nvim_create_autocmd("InsertEnter", {
        callback = function()
          vim.opt.completeopt = { "menu", "menuone" }
        end,
      })
    end,
  },

  -- ============================================================
  -- Treesitter
  -- ============================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "windwp/nvim-ts-autotag" },
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = {
          "javascript",
          "typescript",
          "rust",
          "c",
          "lua",
          "http",
          "json",
          "markdown",
          "python",
          "vimdoc",
          "luadoc",
          "vim",
          "prisma",
        },
        auto_install = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "prisma",
        callback = function()
          vim.treesitter.start()
        end,
      })

      require("nvim-ts-autotag").setup()
    end,
  },

  -- ============================================================
  -- Telescope
  -- ============================================================
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
      { "<leader>pf", desc = "Telescope find files" },
      { "<leader>fs", desc = "Telescope live grep" },
      { "<leader>fr", desc = "Telescope buffers" },
      { "<leader>fd", desc = "Telescope file browser" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
    },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      local trouble = require("trouble.sources.telescope")

      function Telescope_buffer_dir()
        return vim.fn.expand("%:p:h")
      end

      telescope.setup({
        defaults = {
          mappings = {
            i = { ["<c-t>"] = trouble.open },
            n = { ["<c-t>"] = trouble.open },
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
        pickers = {
          live_grep = {
            file_ignore_patterns = { "node_modules", ".git", ".venv" },
            additional_args = function(_)
              return { "--hidden" }
            end,
          },
          find_files = {
            file_ignore_patterns = { "node_modules", ".git", ".venv" },
            hidden = true,
          },
        },
      })

      telescope.load_extension("ui-select")
      telescope.load_extension("file_browser")
      pcall(telescope.load_extension, "harpoon")

      local function find_files()
        builtin.find_files({ find_command = { "rg", "--files", "--hidden", "-g", "!.git" } })
      end

      vim.keymap.set("n", "<leader>pf", find_files, {})
      vim.keymap.set("n", "<leader>fs", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fr", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fd", function()
        telescope.extensions.file_browser.file_browser({
          path = "%:p:h",
          cwd = Telescope_buffer_dir(),
          respoect_git_ignore = false,
          hidden = true,
          grouped = true,
          initial_mode = "normal",
        })
      end)
    end,
  },

  -- ============================================================
  -- Tmux navigation
  -- ============================================================
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>" },
    },
  },

  -- ============================================================
  -- Filetype-specific
  -- ============================================================
  {
    "wuelnerdotexe/vim-astro",
    ft = "astro",
    init = function()
      vim.g.astro_typescript = "enable"
      vim.g.astro_stylus = "enable"
    end,
  },
  {
    "AndrewRadev/tagalong.vim",
    ft = { "html", "xml", "jsx", "tsx", "vue", "svelte", "astro" },
  },
  {
    "nvim-flutter/flutter-tools.nvim",
    ft = "dart",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("flutter-tools").setup({})
    end,
  },

  -- ============================================================
  -- Git
  -- ============================================================
  {
    "kdheepak/lazygit.nvim",
    cmd = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter" },
    keys = {
      { "<leader>gi", "<cmd>LazyGit<cr>", desc = "LazyGit" },
      { "<leader>m", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    commit = "929183666540e164fa74028954ade62fa703fa1a",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { hl = "GitSignsAdd", text = "▎", numhl = "GitSignsAddNr", linehl = "GitSignsAddLn" },
          change = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
          delete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
          topdelete = { hl = "GitSignsDelete", text = "契", numhl = "GitSignsDeleteNr", linehl = "GitSignsDeleteLn" },
          changedelete = { hl = "GitSignsChange", text = "▎", numhl = "GitSignsChangeNr", linehl = "GitSignsChangeLn" },
        },
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
        watch_gitdir = {
          interval = 1000,
          follow_files = true,
        },
        attach_to_untracked = true,
        current_line_blame = true,
        current_line_blame_opts = {
          virt_text = true,
          virt_text_pos = "eol",
          delay = 300,
          ignore_whitespace = false,
        },
        current_line_blame_formatter_opts = {
          relative_time = false,
        },
        sign_priority = 6,
        update_debounce = 100,
        status_formatter = nil,
        max_file_length = 40000,
        preview_config = {
          border = "single",
          style = "minimal",
          relative = "cursor",
          row = 0,
          col = 1,
        },
        yadm = { enable = false },
      })
    end,
  },
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = { "BufReadPre", "BufNewFile" },
    config = true,
  },

  -- ============================================================
  -- UI / Editor extras
  -- ============================================================
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = true,
  },
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
      { "gcc" },
      { "gbc" },
    },
    config = true,
  },
  {
    "ThePrimeagen/harpoon",
    keys = {
      { "<leader>ha", function() require("harpoon.mark").add_file() end, desc = "Harpoon add" },
      { "<leader>ho", function() require("harpoon.ui").toggle_quick_menu() end, desc = "Harpoon menu" },
    },
    config = function()
      require("harpoon").setup({
        menu = {
          width = vim.api.nvim_win_get_width(0) - 40,
        },
      })
    end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  -- ============================================================
  -- Formatter
  -- ============================================================
  {
    "MunifTanjim/prettier.nvim",
    ft = {
      "css",
      "graphql",
      "html",
      "javascript",
      "javascriptreact",
      "json",
      "less",
      "markdown",
      "python",
      "scss",
      "typescript",
      "typescriptreact",
      "yaml",
    },
    config = function()
      require("prettier").setup({
        bin = "prettierd",
        filetypes = {
          "css",
          "graphql",
          "html",
          "javascript",
          "javascriptreact",
          "json",
          "less",
          "markdown",
          "python",
          "scss",
          "typescript",
          "typescriptreact",
          "yaml",
        },
      })
    end,
  },
}, {
  -- Lazy.nvim opts
  install = { colorscheme = { "tokyonight" } },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
