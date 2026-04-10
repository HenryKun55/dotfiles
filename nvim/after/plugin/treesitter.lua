-- Configure treesitter and install desired parsers
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

-- Enable treesitter highlight for non-bundled parsers
vim.api.nvim_create_autocmd("FileType", {
  pattern = "prisma",
  callback = function()
    vim.treesitter.start()
  end,
})

-- Autotag setup (separate from treesitter now)
require("nvim-ts-autotag").setup()
