local builtin = require('telescope.builtin')
local trouble = require("trouble.providers.telescope")

local telescope = require("telescope")

function Telescope_buffer_dir()
  return vim.fn.expand('%:p:h')
end

telescope.setup {
    defaults = {
        mappings = {
            i = { ["<c-t>"] = trouble.open_with_trouble },
            n = { ["<c-t>"] = trouble.open_with_trouble },
        },
    },
    extensions = {
        ["ui-select"] = {
            require("telescope.themes").get_dropdown {
            }
    }
  }
}

telescope.load_extension("ui-select")
telescope.load_extension('file_browser')

vim.keymap.set('n', '<leader>pf', builtin.find_files, {})
vim.keymap.set('n', '<C-p>', builtin.git_files, {})
vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fr', builtin.buffers, {})
vim.keymap.set('n', '<leader>fd', function ()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = Telescope_buffer_dir(),
    respoect_git_ignore = false,
    hidden = true,
    grouped = true,
    initial_mode = "normal"
  })
end)

