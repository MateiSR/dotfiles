vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	term_colors = true,
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
		keywords = { "italic" },
	},
	integrations = {
		blink_cmp = true,
		gitsigns = true,
		leap = true,
		mason = true,
		markdown = true,
		neotree = true,
		native_lsp = {
			enabled = true,
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
		},
		telescope = { enabled = false },
		treesitter = true,
		which_key = true,
		illuminate = { enabled = true },
		indent_blankline = { enabled = true },
		lsp_trouble = true,
		render_markdown = true,
	},
})

vim.cmd.colorscheme("catppuccin")
