vim.pack.add({
	{ src = "https://github.com/RRethy/base16-nvim", name = "base16-nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({
	flavour = "mocha",
	transparent_background = true,
	term_colors = true,
	styles = {
		comments = { "italic" },
		conditionals = { "italic" },
		keywords = { "italic" },
	},
	integrations = {
		blink_cmp = true,
		gitsigns = true,
		leap = true,
		mason = true,
		markdown = true,
		neotree = true,
		native_lsp = {
			enabled = true,
			underlines = {
				errors = { "undercurl" },
				hints = { "undercurl" },
				warnings = { "undercurl" },
				information = { "undercurl" },
			},
		},
		telescope = { enabled = false },
		treesitter = true,
		which_key = true,
		illuminate = { enabled = true },
		indent_blankline = { enabled = true },
		lsp_trouble = true,
		render_markdown = true,
	},
})

local matugen_path = vim.fn.stdpath("config") .. "/matugen.lua"

local function load_matugen()
	if not vim.uv.fs_stat(matugen_path) then
		return false
	end

	local ok, err = pcall(dofile, matugen_path)
	if not ok then
		vim.notify("Could not load the Matugen theme: " .. err, vim.log.levels.ERROR)
		return false
	end

	vim.g.matugen_theme_loaded = true
	vim.g.colors_name = "matugen"
	vim.api.nvim_exec_autocmds("ColorScheme", { pattern = "matugen", modeline = false })
	return true
end

if not load_matugen() then
	vim.g.matugen_theme_loaded = false
	vim.cmd.colorscheme("catppuccin")
end

local group = vim.api.nvim_create_augroup("matugen_reload", { clear = true })
vim.api.nvim_create_autocmd("Signal", {
	group = group,
	pattern = "SIGUSR1",
	callback = function()
		if load_matugen() then
			vim.api.nvim_exec_autocmds("User", { pattern = "MatugenReload", modeline = false })
			vim.cmd.redraw()
		end
	end,
})
