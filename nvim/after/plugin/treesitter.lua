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
  "prisma",
})

-- Enable treesitter highlight for non-bundled parsers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "prisma",
  callback = function()
    vim.treesitter.start()
  end,
})

-- Autotag setup (separate from treesitter now)
require("nvim-ts-autotag").setup()
