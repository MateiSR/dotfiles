vim.pack.add({
	"https://github.com/Bekaboo/dropbar.nvim",
})

require("dropbar").setup({
	bar = {
		enable = function(buf, win)
			if vim.bo[buf].filetype == "neo-tree" then
				return false
			end
			return vim.fn.win_gettype(win) == "" and vim.bo[buf].buftype == "" and vim.bo[buf].filetype ~= "help"
		end,
	},
})

local dropbar_api = require("dropbar.api")
vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
