local lsp = require("lspconfig")
local tw_highlight = require('tailwind-highlight')

lsp.tailwindcss.setup {
  settings = {
    scss = { validate = false },
    editor = {
      quickSuggestions = { strings = true },
      autoClosingQuotes = 'always',
    },
    tailwindCSS = {
      experimental = {
        classRegex = {
          'tw`([^`]*)',                                                        -- tw`...`
          'tw="([^"]*)',                                                       -- <div tw="..." />
          'tw={"([^"}]*)',                                                     -- <div tw={"..."} />
          'tw\\.\\w+`([^`]*)',                                                 -- tw.xxx`...`
          'tw\\(.*?\\)`([^`]*)',                                               -- tw(Component)`...`
          { "tv\\((([^()]*|\\([^()]*\\))*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" }, -- tv({...})
        },
      },
      includeLanguages = {
        typescript = 'javascript',
        typescriptreact = 'javascript',
      },
    },
  },
  on_attach = function(client, bufnr)
    tw_highlight.setup(client, bufnr, {})
  end
}
