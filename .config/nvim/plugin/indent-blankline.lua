vim.pack.add({
	"https://github.com/lukas-reineke/indent-blankline.nvim",
})

require("ibl").setup({
	indent = { char = "│" },
	scope = { enabled = true },
	exclude = {
		buftypes = { "terminal", "nofile" },
		filetypes = { "help", "dashboard", "neo-tree", "Trouble", "lazy", "man" },
	},
})
