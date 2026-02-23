vim.lsp.config('cssls', {
  settings = {
    css = {
      validate = true
    },
    lint = {
      unknownAtRules = 'ignore',
    },
  }
})

vim.lsp.enable('cssls')

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = false,
})
