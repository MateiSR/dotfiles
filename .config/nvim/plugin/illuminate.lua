vim.pack.add({
	"https://github.com/RRethy/vim-illuminate",
})

require("illuminate").configure({
	delay = 200,
	filetypes_denylist = {
		"neo-tree",
		"lazy",
		"Trouble",
		"alpha",
		"toggleterm",
		"TelescopePrompt",
	},
})
