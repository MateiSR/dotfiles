vim.pack.add({
	"https://github.com/folke/trouble.nvim",
})

require("trouble").setup()

vim.keymap.set("n", "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })
vim.keymap.set(
	"n",
	"<leader>xd",
	"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
	{ desc = "Buffer Diagnostics (Trouble)" }
)
vim.keymap.set("n", "<leader>xq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix List (Trouble)" })
vim.keymap.set("n", "<leader>xl", "<cmd>Trouble loclist toggle<cr>", { desc = "Location List (Trouble)" })
vim.keymap.set("n", "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", { desc = "Symbols (Trouble)" })
vim.keymap.set("n", "gR", "<cmd>Trouble lsp_references toggle<cr>", { desc = "LSP References (Trouble)" })
