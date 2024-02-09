require 'lspconfig'.tsserver.setup {
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function()
    return
        util.root_pattern('tsconfig.json')(fname)
        or util.root_pattern('package.json', 'jsconfig.json', '.git')(fname)
        or util.path.dirname(fname)
  end
}
