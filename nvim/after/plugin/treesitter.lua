-- Install desired parsers (skips already installed)
require("nvim-treesitter").install({
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
})

-- Treesitter highlight is enabled by default in Neovim 0.11+

-- Autotag setup (separate from treesitter now)
require("nvim-ts-autotag").setup()
