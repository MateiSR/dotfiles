return {
	{
		"saghen/blink.cmp",
		dependencies = {
			"Kaiser-Yang/blink-cmp-avante",
			"rafamadriz/friendly-snippets",
		},
		version = "1.*",
		opts = {
			keymap = { preset = "default" },
			appearance = { nerd_font_variant = "mono" },
			snippets = {
				expand = function(snippet)
					vim.snippet.expand(snippet)
				end,
				active = function(filter)
					return vim.snippet.active(filter)
				end,
				jump = function(direction)
					vim.snippet.jump(direction)
				end,
			},
			completion = {
				accept = {
					auto_brackets = { enabled = true },
				},
				menu = {
					border = "rounded",
					draw = { treesitter = { "lsp" } },
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					window = { border = "rounded" },
				},
			},
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					["Avante"] = { "avante" },
					["AvanteInput"] = { "avante" },
				},
				providers = {
					snippets = {
						opts = {
							friendly_snippets = true,
						},
					},
					avante = {
						name = "Avante",
						module = "blink-cmp-avante",
					},
				},
			},
		},
	},
}
