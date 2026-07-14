vim.pack.add({
	{
		src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
		version = vim.version.range("3"),
	},
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

vim.keymap.set("n", "<C-n>", ":Neotree filesystem reveal left<CR>", { desc = "Neotree reveal", silent = true })
vim.keymap.set("n", "<C-S-n>", ":Neotree filesystem toggle<CR>", { desc = "Neotree toggle", silent = true })

require("neo-tree").setup({
	filesystem = {
		filtered_items = {
			hide_dotfiles = false,
			hide_gitignored = false,
			hide_by_name = { "package-lock.json" },
		},
	},
})
