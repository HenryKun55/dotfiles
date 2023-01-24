local lsp = require ("lspconfig")
lsp.tailwindcss.setup{
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {
          'tw([^])',
          'tw="([^"])',
          'tw={"([^"}])',
          'tw\\.\\w+([^])',
          'tw\\(.?\\)([^])',
        }
      },
    },
  },
}
