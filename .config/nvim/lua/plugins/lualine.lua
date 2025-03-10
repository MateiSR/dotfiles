return {
	"nvim-lualine/lualine.nvim",
	config = function()
		-- Require the necessary modules
		local lualine = require("lualine")

		-- Setup lualine with the custom theme
		lualine.setup({
			options = {
				theme = "kanagawa",
				section_separators = { left = "", right = "" },
				component_separators = { left = "", right = "" },
			},
			sections = {

				lualine_a = {
					{
						function()
							-- "mode" which also shows the recording macro
							local reg = vim.fn.reg_recording()
							-- If a macro is being recorded, show "Recording @<register>"
							if reg ~= "" then
								return "Recording @" .. reg
							else
								-- Get the full mode name using nvim_get_mode()
								local mode = vim.api.nvim_get_mode().mode
								local mode_map = {
									n = "NORMAL",
									i = "INSERT",
									v = "VISUAL",
									V = "V-LINE",
									["^V"] = "V-BLOCK",
									c = "COMMAND",
									R = "REPLACE",
									s = "SELECT",
									S = "S-LINE",
									["^S"] = "S-BLOCK",
									t = "TERMINAL",
								}

								-- Return the full mode name
								return mode_map[mode] or mode:upper()
							end
						end,
					},
				},
				lualine_b = { "branch" },
				lualine_c = { "filename" },
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			tabline = {},
			extensions = {},
		})
	end,
}
