-- mason.nvim coloca o mason/bin no PATH, e o nvim-lspconfig fornece os
-- configs em lsp/*.lua. Ambos são lazy, então num cold start (nvim arquivo.php)
-- o FileType pode disparar antes deles estarem no runtimepath e nenhum LSP
-- anexa. Forçamos o load aqui, antes do vim.lsp.enable, pra eliminar a corrida.
pcall(function()
  require('lazy').load({ plugins = { 'mason.nvim', 'mason-lspconfig.nvim', 'nvim-lspconfig' } })
end)

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

-- Rust: usa o rust-analyzer do rustup (~/.cargo/bin), que fica na mesma ABI do
-- toolchain e evita erros de proc-macro da cópia do Mason. Só habilitamos se o
-- binário existir, mantendo o config defensivo em máquina sem Rust instalado.
if vim.fn.executable('rust-analyzer') == 1 then
  vim.lsp.config('rust_analyzer', {
    settings = {
      ['rust-analyzer'] = {
        check = { command = 'clippy' },
      },
    },
  })
  vim.lsp.enable('rust_analyzer')
end

-- C/C++: clangd vem do Xcode Command Line Tools (/usr/bin/clangd), então não
-- depende do Mason. Defensivo: só habilita se o binário existir. O --clang-tidy
-- usa o tidy embutido do clangd (não precisa do binário standalone). Pra projetos
-- reais, gere um compile_commands.json (cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON).
if vim.fn.executable('clangd') == 1 then
  vim.lsp.config('clangd', {
    cmd = {
      'clangd',
      '--background-index',
      '--clang-tidy',
      '--header-insertion=iwyu',
      '--completion-style=detailed',
    },
  })
  vim.lsp.enable('clangd')
end

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

