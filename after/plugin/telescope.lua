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
  },
  pickers = {
    live_grep = {
      file_ignore_patterns = { 'node_modules', '.git', '.venv' },
      additional_args = function(_)
        return { "--hidden" }
      end
    },
    find_files = {
      file_ignore_patterns = { 'node_modules', '.git', '.venv' },
      hidden = true
    }
  }
}

telescope.load_extension("ui-select")
telescope.load_extension('file_browser')
telescope.load_extension('harpoon')

local function find_files()
  builtin.find_files({ find_command = { 'rg', '--files', '--hidden', '-g', '!.git' } })
end

vim.keymap.set('n', '<leader>pf', find_files, {})
vim.keymap.set('n', '<leader>fs', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fr', builtin.buffers, {})
vim.keymap.set('n', '<leader>fd', function()
  telescope.extensions.file_browser.file_browser({
    path = "%:p:h",
    cwd = Telescope_buffer_dir(),
    respoect_git_ignore = false,
    hidden = true,
    grouped = true,
    initial_mode = "normal"
  })
end)
