function ColorMyPencils(color)
	color = color or "one-nvim"
	vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalFlot", { bg = "NONE" })
end

ColorMyPencils()
