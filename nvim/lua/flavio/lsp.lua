-- Vue LSP
local vue_language_server_path = vim.fn.expand('$HOME/.local/share/nvim/mason/packages/vue-language-server/node_modules/@vue/language-server')

local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path,
  languages = { 'vue' },
  configNamespace = 'typescript',
}

vim.lsp.config('ts_ls', {
  init_options = {
    plugins = { vue_plugin },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})

vim.lsp.config('vue_ls', {})

vim.lsp.config('laravel_ls', {})

vim.lsp.enable({ 'ts_ls', 'vue_ls', 'laravel_ls' })

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
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '●',
      [vim.diagnostic.severity.WARN]  = '●',
      [vim.diagnostic.severity.INFO]  = '●',
      [vim.diagnostic.severity.HINT]  = '●',
    },
  },
  update_in_insert = false,
  underline = true,
  severity_sort = false,
})

