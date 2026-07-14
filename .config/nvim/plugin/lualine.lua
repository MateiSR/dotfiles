vim.pack.add({
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
})

local function setup()
	package.loaded["lualine.themes.base16"] = nil
	require("lualine").setup({
		options = {
			theme = vim.g.matugen_theme_loaded and "base16" or "auto",
			section_separators = { left = "", right = "" },
			component_separators = { left = "", right = "" },
		},
		sections = {
			lualine_a = {
				{
					function()
						local reg = vim.fn.reg_recording()
						if reg ~= "" then
							return "Recording @" .. reg
						end
						return vim.api.nvim_get_mode().mode:upper()
					end,
				},
			},
			lualine_b = { "branch" },
			lualine_c = { "filename" },
			lualine_x = { "encoding", "fileformat", "filetype" },
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
	})
end

setup()

vim.api.nvim_create_autocmd("User", {
	pattern = "MatugenReload",
	callback = setup,
})
