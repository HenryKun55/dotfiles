local lspconfig = require("lspconfig")

require("lsp-zero").on_attach(
  function(_, bufnr)
  end
)

lspconfig.cssls.setup({
  settings = {
    css = {
      validate = true
    },
    lint = {
      unknownAtRules = 'ignore',
    },
  }
})

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
})
