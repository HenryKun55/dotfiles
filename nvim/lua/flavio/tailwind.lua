vim.lsp.config('tailwindcss', {
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
    require('tailwind-highlight').setup(client, bufnr, {})
  end
})

vim.lsp.enable('tailwindcss')
