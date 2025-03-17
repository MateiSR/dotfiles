return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup({})

		vim.keymap.set("n", "hj", function()
			harpoon:list():prev()
		end, { desc = "Go to next harpoon file" })
		vim.keymap.set("n", "hk", function()
			harpoon:list():next()
		end, { desc = "Go to previous harpoon file" })
		vim.keymap.set("n", "hx", function()
			harpoon:list():add()
		end)
		vim.keymap.set("n", "hg", function()
			harpoon.ui:toggle_quick_menu(harpoon:list())
		end)
	end,
}
