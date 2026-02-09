return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	opts = {
		filesystem = {
			filtered_items = {
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_by_name = {
					"package-lock.json",
				},
			},
		},
	},
	keys = {
		{ "<C-n>", ":Neotree filesystem reveal left<CR>", desc = "Neotree reveal" },
		{ "<C-S-n>", ":Neotree filesystem toggle<CR>", desc = "Neotree toggle" },
	},
}
