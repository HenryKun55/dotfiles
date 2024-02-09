local lsp = require('lsp-zero')
lsp.preset('recommended')

local capabilities = require('cmp_nvim_lsp').default_capabilities()

lsp.setup {
  capabilities = capabilities
}

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
})
