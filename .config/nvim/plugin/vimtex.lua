vim.pack.add({"https://github.com/lervag/vimtex"})

vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_compiler_method = "latexmk"
vim.g.vimtex_compiler_latexmk = {
	options = {
		"-pdf",
		"-shell-escape",
		"-synctex=1",
		"-interaction=nonstopmode",
		"-f",
	},
}

-- Disable vimtex's own insert-mode mappings so blink.cmp stays in charge
vim.g.vimtex_imaps_enabled = 0
