require'lspconfig'.tsserver.setup{
  filetypes = { "javascript", "typescript", "typescriptreact", "typescript.tsx" },
  root_dir = function() return vim.loop.cwd() end
}
