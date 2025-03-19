return {
	{
		"mattn/emmet-vim",
		ft = {
			"html",
			"css",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"vue",
			"svelte",
			"php",
			"xml",
			"jsx",
			"tsx",
		},
		init = function()
			-- Optional: Configure Emmet settings
			vim.g.user_emmet_leader_key = "<C-y>" -- default is <C-y>
			vim.g.user_emmet_mode = "a" -- enable all functions, can be 'n', 'i', or 'a' for normal, insert, or all modes
			vim.g.user_emmet_install_global = 0 -- disable global installation
			vim.cmd([[autocmd FileType html,css,javascript,javascriptreact,typescript,typescriptreact,vue,svelte,php,xml,jsx,tsx EmmetInstall]])
		end,
	},
}
