return {
	{
		"yetone/avante.nvim",
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		-- ⚠️ must add this setting! ! !
		build = vim.fn.has("win32") ~= 0
				and "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
			or "make",
		event = "VeryLazy",
		version = false, -- Never set this value to "*"! Never!
		---@module 'avante'
		---@type avante.Config
		opts = {
			-- add any opts here
			-- this file can contain specific instructions for your project
			instructions_file = "avante.md",
			-- for example
			provider = "copilot",
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"nvim-mini/mini.pick", -- for file_selector provider mini.pick
			"nvim-telescope/telescope.nvim", -- for file_selector provider telescope
			"Kaiser-Yang/blink-cmp-avante", -- autocompletion for avante commands and mentions
			"ibhagwan/fzf-lua", -- for file_selector provider fzf
			"stevearc/dressing.nvim", -- for input provider dressing
			"folke/snacks.nvim", -- for input provider snacks
			"nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
			"zbirenbaum/copilot.lua", -- for providers='copilot'
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
	},
	{
		"zbirenbaum/copilot.lua",
		dependencies = {
			{ "copilotlsp-nvim/copilot-lsp" }, -- optional, for Copilot LSP (NES features)
		},
		cmd = "Copilot", -- loads only when you run :Copilot
		event = "InsertEnter", -- or load when entering Insert mode
		config = function()
			require("copilot").setup({
				suggestion = {
					enabled = true,
					auto_trigger = true,
					debounce = 75,
					keymap = {
						-- Main accept key - Tab is most common
						-- accept = "<Tab>",
						-- Alternative: use <C-j> if Tab conflicts with other plugins
						accept = "<C-j>",

						-- Accept only the next word
						accept_word = "<M-w>", -- Alt+w

						-- Accept only the current line
						accept_line = "<M-l>", -- Alt+l

						-- Navigate between suggestions
						next = "<M-]>", -- Alt+]
						prev = "<M-[>", -- Alt+[

						-- Dismiss the current suggestion
						dismiss = "<C-]>", -- Ctrl+]
					},
				},
				panel = {
					enabled = true,
					auto_refresh = false,
					keymap = {
						jump_prev = "[[",
						jump_next = "]]",
						accept = "<CR>",
						refresh = "gr",
						open = "<M-CR>", -- Alt+Enter to open panel
					},
					layout = {
						position = "bottom", -- | top | left | right
						ratio = 0.4,
					},
				},
				filetypes = {
					markdown = true,
					help = true,
					gitcommit = true,
					gitrebase = true,
					hgcommit = true,
					svn = true,
					cvs = true,
					-- Disable Copilot in Avante-specific buffers to avoid conflicts
					Avante = false,
					AvanteInput = false,
					["*"] = true, -- Enable for all other filetypes
				},
				copilot_node_command = "node", -- Node.js version must be > 18.x
				server_opts_overrides = {},
			})

			-- Optional: Additional custom keymaps
			-- Accept suggestion with Ctrl+J (alternative to Tab)
			vim.keymap.set("i", "<C-j>", function()
				require("copilot.suggestion").accept()
			end, { desc = "Accept Copilot suggestion" })

			-- Toggle Copilot suggestions on/off
			vim.keymap.set("n", "<leader>ct", function()
				require("copilot.suggestion").toggle_auto_trigger()
			end, { desc = "Toggle Copilot auto suggestions" })
		end,
	},
}
