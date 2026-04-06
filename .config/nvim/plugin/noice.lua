vim.pack.add({
	"https://github.com/folke/noice.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
})

require("noice").setup({
	lsp = {
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
		},
	},
	presets = {
		bottom_search = true,
		command_palette = true,
		long_message_to_split = true,
		lsp_doc_border = true,
	},
	-- Use mini view instead of nvim-notify
	views = {
		mini = {
			timeout = 2000,
		},
	},
	routes = {
		-- Skip "written" messages
		{ filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
		-- Skip search count messages
		{ filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
	},
})
