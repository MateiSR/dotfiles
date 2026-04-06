vim.pack.add({
	"https://github.com/zbirenbaum/copilot.lua",
})

require("copilot").setup({
	suggestion = {
		enabled = true,
		auto_trigger = true,
		debounce = 75,
		keymap = {
			accept = "<C-j>",
			accept_word = "<M-w>",
			accept_line = "<M-l>",
			next = "<M-]>",
			prev = "<M-[>",
			dismiss = "<C-]>",
		},
	},
	panel = { enabled = true },
	filetypes = {
		Avante = false,
		AvanteInput = false,
		["*"] = true,
	},
})

vim.keymap.set("n", "<leader>ct", function()
	require("copilot.suggestion").toggle_auto_trigger()
end, { desc = "Toggle Copilot" })
