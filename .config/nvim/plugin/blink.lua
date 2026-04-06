vim.pack.add({
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.*") },
	"https://github.com/rafamadriz/friendly-snippets",
})

require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = {
		accept = { auto_brackets = { enabled = true } },
		menu = { border = "rounded" },
		documentation = {
			auto_show = true,
			auto_show_delay_ms = 200,
			window = { border = "rounded" },
		},
	},
	sources = {
		default = { "lsp", "path", "snippets", "buffer" },
	},
})
