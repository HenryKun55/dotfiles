function ColorMyPencils(color)
	color = color or "tokyonight-moon"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", {})
	vim.api.nvim_set_hl(0, "NormalFloat", {})
  vim.api.nvim_set_option_value("colorcolumn", "0", {})
end

ColorMyPencils()
