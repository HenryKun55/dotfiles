-- Configure treesitter and install desired parsers
require("nvim-treesitter.configs").setup({
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
  },
  auto_install = true,
})

-- Treesitter highlight is enabled by default in Neovim 0.11+

-- Autotag setup (separate from treesitter now)
require("nvim-ts-autotag").setup()
