vim.pack.add({
	"https://github.com/goolord/alpha-nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

local dashboard = require("alpha.themes.dashboard")

dashboard.section.header.val = {
	"                                ",
	"  ███╗   ██╗██╗   ██╗██╗███╗   ███╗",
	"  ████╗  ██║██║   ██║██║████╗ ████║",
	"  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
	"  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
	"  ██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
	"  ╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═╝",
	"                                ",
}

dashboard.section.buttons.val = {
	dashboard.button("f", "  Find file", "<cmd>Telescope find_files<CR>"),
	dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<CR>"),
	dashboard.button("g", "  Find text", "<cmd>Telescope live_grep<CR>"),
	dashboard.button("c", "  Config", "<cmd>e ~/.config/nvim/<CR>"),
	dashboard.button("q", "  Quit", "<cmd>qa<CR>"),
}

require("alpha").setup(dashboard.opts)
