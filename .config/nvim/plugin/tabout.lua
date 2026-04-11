vim.pack.add({
	"https://github.com/abecodes/tabout.nvim",
})

require("tabout").setup({
	tabkey = "<Tab>",
	backwards_tabkey = "<S-Tab>",
	act_as_tab = true,
	act_as_shift_tab = false,
	default_tab = "<C-t>",
	default_shift_tab = "<C-d>",
	enable_backwards = true,
	completion = false, -- set true if you want tabout to wait for completion menu
	tabouts = {
		{ open = "'", close = "'" },
		{ open = '"', close = '"' },
		{ open = "`", close = "`" },
		{ open = "(", close = ")" },
		{ open = "[", close = "]" },
		{ open = "{", close = "}" },
	},
	ignore_beginning = true,
	exclude = {},
})
