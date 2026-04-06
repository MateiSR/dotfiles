vim.pack.add({
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/echasnovski/mini.nvim",
})

require("mini.bufremove").setup()

require("bufferline").setup({
	highlights = require("catppuccin.special.bufferline").get_theme(),
	options = {
		numbers = "ordinal",
		diagnostics = "nvim_lsp",
		indicator = { style = "underline" },
		close_command = function(n)
			require("mini.bufremove").delete(n, false)
		end,
		name_formatter = function(buf)
			return vim.fn.pathshorten(vim.fn.fnamemodify(buf.path, ":."))
		end,
		max_name_length = 50,
		truncate_names = false,
		offsets = {
			{ filetype = "neo-tree", text = "File Explorer", highlight = "Directory", text_align = "left" },
		},
		show_close_icon = false,
		show_buffer_close_icons = false,
	},
})

local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<A-c>", function()
	require("mini.bufremove").delete(0, false)
end, opts)
vim.keymap.set("n", "<S-Tab>", "<Cmd>BufferLineCyclePrev<CR>", opts)
vim.keymap.set("n", "<Tab>", "<Cmd>BufferLineCycleNext<CR>", opts)
vim.keymap.set("n", "<A-1>", "<Cmd>BufferLineGoToBuffer 1<CR>", opts)
vim.keymap.set("n", "<A-2>", "<Cmd>BufferLineGoToBuffer 2<CR>", opts)
vim.keymap.set("n", "<A-3>", "<Cmd>BufferLineGoToBuffer 3<CR>", opts)
vim.keymap.set("n", "<A-4>", "<Cmd>BufferLineGoToBuffer 4<CR>", opts)
vim.keymap.set("n", "<A-5>", "<Cmd>BufferLineGoToBuffer 5<CR>", opts)
vim.keymap.set("n", "<A-6>", "<Cmd>BufferLineGoToBuffer 6<CR>", opts)
vim.keymap.set("n", "<A-7>", "<Cmd>BufferLineGoToBuffer 7<CR>", opts)
vim.keymap.set("n", "<A-8>", "<Cmd>BufferLineGoToBuffer 8<CR>", opts)
vim.keymap.set("n", "<A-9>", "<Cmd>BufferLineGoToBuffer 9<CR>", opts)
vim.keymap.set("n", "<A-0>", "<Cmd>BufferLineGoToBuffer -1<CR>", opts)
