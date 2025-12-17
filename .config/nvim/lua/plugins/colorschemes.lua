return {
	-- TODO: add colorscheme menu
	{
		"rebelot/kanagawa.nvim",
		lazy = false,
		enabled = false,
		name = "kanagawa",
		priority = 1000,
		config = function()
			vim.cmd.colorscheme("kanagawa-dragon")
			require("kanagawa").setup({
				compile = true,
				undercurl = true,
				commentStyle = { italic = true },
				functionStyle = {},
				keywordStyle = { italic = true },
				statementStyle = { bold = true },
				typeStyle = {},
				transparent = true,
				dimInactive = false,
				terminalColors = true,
				theme = "dragon",
				background = {
					dark = "dragon",
					light = "lotus",
				},
				overrides = function(colors)
					local theme = colors.theme
					return {
						Pmenu = { fg = theme.ui.shade0, bg = theme.ui.bg_p1, blend = vim.o.pumblend },
						PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
						PmenuSbar = { bg = theme.ui.bg_m1 },
						PmenuThumb = { bg = theme.ui.bg_p2 },
						BlinkCmpMenuBorder = { fg = "", bg = "" },
						NormalFloat = { bg = "none" },
						FloatBorder = { bg = "none" },
						FloatTitle = { bg = "none" },
						-- LineNr = { fg = "#C0A36E", bg = "NONE" },
						CursorLineNr = { fg = colors.palette.sakuraPink, bg = "NONE" },
					}
				end,
			})
			vim.cmd("silent! KanagawaCompile")
		end,
	},
	{
		"sainnhe/gruvbox-material",
		enabled = false,
		priority = 1000,
		config = function()
			vim.g.gruvbox_material_transparent_background = 0
			vim.g.gruvbox_material_foreground = "mix"
			vim.g.gruvbox_material_background = "hard" -- soft, medium, hard
			vim.g.gruvbox_material_ui_contrast = "high" -- The contrast of line numbers, indent lines, etc.
			vim.g.gruvbox_material_float_style = "bright" -- Background of floating windows
			vim.g.gruvbox_material_statusline_style = "material"
			vim.g.gruvbox_material_cursor = "auto"

			-- vim.g.gruvbox_material_colors_override = { bg0 = '#000000' } -- #0e1010
			-- vim.g.gruvbox_material_colors_override = { bg0 = "#121212" }
			-- vim.g.gruvbox_material_better_performance = 1

			vim.cmd.colorscheme("gruvbox-material")
		end,
	},
	{
		"EdenEast/nightfox.nvim",
		enabled = false,
		priority = 1000,
		config = function()
			require("nightfox").load()
			vim.cmd.colorscheme("nightfox")
		end,
	},
	{
		"folke/tokyonight.nvim",
		enabled = false,
		priority = 1000,
		config = function()
			vim.g.tokyonight_style = "night"
			vim.g.tokyonight_italic_functions = true
			vim.g.tokyonight_italic_variables = true
			vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
			vim.g.tokyonight_colors = { hint = "orange", error = "#ff0000" }
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"shaunsingh/moonlight.nvim",
		enabled = false,
		priority = 1000,
		config = function()
			require("moonlight").setup({
				contrast = true, -- Enable contrast for sidebars, floating windows and popup menus like Nvim-Tree
				borders = false, -- Enable borders between verticaly split windows
				italic_comments = true, -- Enable italic comments
				italic_keywords = true, -- Enable italic keywords
				italic_functions = true, -- Enable italic functions
				italic_variables = false, -- Enable italic variables
				transparent = false, -- Enable the theme to be transparent
				hide_inactive_statusline = true, -- Hide the inactive statusline
				darker_black = false, -- Reduce the brightness of the black background
				-- custom_highlights = {}, -- Overwrite highlights with your own
				-- custom_colors = {}, -- Override the default colors
			})
			vim.cmd.colorscheme("moonlight")
		end,
	},
	{
		"marko-cerovac/material.nvim",
		enabled = false,
		priority = 1000,
		config = function()
			vim.g.material_style = "deep ocean"
			vim.g.material_italic_comments = true
			vim.g.material_italic_keywords = true
			vim.g.material_italic_functions = true
			vim.g.material_italic_variables = true
			vim.g.material_contrast = true
			vim.g.material_borders = false
			vim.g.material_disable_background = false
			vim.g.material_hide_eob = false
			vim.cmd.colorscheme("material")
		end,
	},
	{
		"catppuccin/nvim",
		priority = 1000,
		name = "catppuccin",
		enabled = false,
		config = function()
			require("catppuccin").setup({

				-- transparent_background = false, -- disables setting the background color.
				-- integrations = {
				--   which_key = true,
				--   cmp = true,
				--   gitsigns = true,
				--   treesitter = true,
				--   notify = false,
				--   telescope = {
				--     enabled = true,
				--     style = "nvchad",
				--   },
				-- },
				background = {
					light = "latte",
					dark = "mocha",
				},
				color_overrides = {
					latte = {
						rosewater = "#c14a4a",
						flamingo = "#c14a4a",
						red = "#c14a4a",
						maroon = "#c14a4a",
						pink = "#945e80",
						mauve = "#945e80",
						peach = "#c35e0a",
						yellow = "#b47109",
						green = "#6c782e",
						teal = "#4c7a5d",
						sky = "#4c7a5d",
						sapphire = "#4c7a5d",
						blue = "#45707a",
						lavender = "#45707a",
						text = "#654735",
						subtext1 = "#73503c",
						subtext0 = "#805942",
						overlay2 = "#8c6249",
						overlay1 = "#8c856d",
						overlay0 = "#a69d81",
						surface2 = "#bfb695",
						surface1 = "#d1c7a3",
						surface0 = "#e3dec3",
						base = "#f9f5d7",
						mantle = "#f0ebce",
						crust = "#e8e3c8",
					},
					mocha = {
						rosewater = "#ea6962",
						flamingo = "#ea6962",
						red = "#ea6962",
						maroon = "#ea6962",
						pink = "#d3869b",
						mauve = "#d3869b",
						peach = "#e78a4e",
						yellow = "#d8a657",
						green = "#a9b665",
						teal = "#89b482",
						sky = "#89b482",
						sapphire = "#89b482",
						blue = "#7daea3",
						lavender = "#7daea3",
						text = "#ebdbb2",
						subtext1 = "#d5c4a1",
						subtext0 = "#bdae93",
						overlay2 = "#a89984",
						overlay1 = "#928374",
						overlay0 = "#595959",
						surface2 = "#4d4d4d",
						surface1 = "#404040",
						surface0 = "#292929",
						base = "#1d2021",
						mantle = "#191b1c",
						crust = "#141617",
					},
				},
				transparent_background = false,
				show_end_of_buffer = false,
				integration_default = false,
				integrations = {
					barbecue = { dim_dirname = true, bold_basename = true, dim_context = false, alt_background = false },
					cmp = true,
					gitsigns = true,
					hop = true,
					illuminate = { enabled = true },
					native_lsp = { enabled = true, inlay_hints = { background = true } },
					neogit = true,
					neotree = true,
					semantic_tokens = true,
					treesitter = true,
					treesitter_context = true,
					vimwiki = true,
					which_key = true,
					aerial = true,
					fidget = true,
					mason = true,
					neotest = true,
					dap_ui = true,
					telescope = {
						enabled = true,
						style = "nvchad",
					},
				},
				highlight_overrides = {
					all = function(colors)
						return {
							CmpItemMenu = { fg = colors.surface2 },
							CursorLineNr = { fg = colors.text },
							FloatBorder = { bg = colors.base, fg = colors.surface0 },
							GitSignsChange = { fg = colors.peach },
							LineNr = { fg = colors.overlay0 },
							LspInfoBorder = { link = "FloatBorder" },
							NeoTreeDirectoryIcon = { fg = colors.subtext1 },
							NeoTreeDirectoryName = { fg = colors.subtext1 },
							NeoTreeFloatBorder = { link = "TelescopeResultsBorder" },
							NeoTreeGitConflict = { fg = colors.red },
							NeoTreeGitDeleted = { fg = colors.red },
							NeoTreeGitIgnored = { fg = colors.overlay0 },
							NeoTreeGitModified = { fg = colors.peach },
							NeoTreeGitStaged = { fg = colors.green },
							NeoTreeGitUnstaged = { fg = colors.red },
							NeoTreeGitUntracked = { fg = colors.green },
							NeoTreeIndent = { fg = colors.surface1 },
							NeoTreeNormal = { bg = colors.mantle },
							NeoTreeNormalNC = { bg = colors.mantle },
							NeoTreeRootName = { fg = colors.subtext1, style = { "bold" } },
							NeoTreeTabActive = { fg = colors.text, bg = colors.mantle },
							NeoTreeTabInactive = { fg = colors.surface2, bg = colors.crust },
							NeoTreeTabSeparatorActive = { fg = colors.mantle, bg = colors.mantle },
							NeoTreeTabSeparatorInactive = { fg = colors.crust, bg = colors.crust },
							NeoTreeWinSeparator = { fg = colors.base, bg = colors.base },
							NormalFloat = { bg = colors.base },
							Pmenu = { bg = colors.mantle, fg = "" },
							PmenuSel = { bg = colors.surface0, fg = "" },
							VertSplit = { bg = colors.base, fg = colors.surface0 },
							WhichKeyFloat = { bg = colors.mantle },
							YankHighlight = { bg = colors.surface2 },
							FidgetTask = { fg = colors.subtext1 },
							FidgetTitle = { fg = colors.peach },

							IblIndent = { fg = colors.surface0 },
							IblScope = { fg = colors.overlay0 },

							Boolean = { fg = colors.mauve },
							Number = { fg = colors.mauve },
							Float = { fg = colors.mauve },

							PreProc = { fg = colors.mauve },
							PreCondit = { fg = colors.mauve },
							Include = { fg = colors.mauve },
							Define = { fg = colors.mauve },
							Conditional = { fg = colors.red },
							Repeat = { fg = colors.red },
							Keyword = { fg = colors.red },
							Typedef = { fg = colors.red },
							Exception = { fg = colors.red },
							Statement = { fg = colors.red },

							Error = { fg = colors.red },
							StorageClass = { fg = colors.peach },
							Tag = { fg = colors.peach },
							Label = { fg = colors.peach },
							Structure = { fg = colors.peach },
							Operator = { fg = colors.peach },
							Title = { fg = colors.peach },
							Special = { fg = colors.yellow },
							SpecialChar = { fg = colors.yellow },
							Type = { fg = colors.yellow, style = { "bold" } },
							Function = { fg = colors.green, style = { "bold" } },
							Delimiter = { fg = colors.subtext1 },
							Ignore = { fg = colors.subtext1 },
							Macro = { fg = colors.teal },

							TSAnnotation = { fg = colors.mauve },
							TSAttribute = { fg = colors.mauve },
							TSBoolean = { fg = colors.mauve },
							TSCharacter = { fg = colors.teal },
							TSCharacterSpecial = { link = "SpecialChar" },
							TSComment = { link = "Comment" },
							TSConditional = { fg = colors.red },
							TSConstBuiltin = { fg = colors.mauve },
							TSConstMacro = { fg = colors.mauve },
							TSConstant = { fg = colors.text },
							TSConstructor = { fg = colors.green },
							TSDebug = { link = "Debug" },
							TSDefine = { link = "Define" },
							TSEnvironment = { link = "Macro" },
							TSEnvironmentName = { link = "Type" },
							TSError = { link = "Error" },
							TSException = { fg = colors.red },
							TSField = { fg = colors.blue },
							TSFloat = { fg = colors.mauve },
							TSFuncBuiltin = { fg = colors.green },
							TSFuncMacro = { fg = colors.green },
							TSFunction = { fg = colors.green },
							TSFunctionCall = { fg = colors.green },
							TSInclude = { fg = colors.red },
							TSKeyword = { fg = colors.red },
							TSKeywordFunction = { fg = colors.red },
							TSKeywordOperator = { fg = colors.peach },
							TSKeywordReturn = { fg = colors.red },
							TSLabel = { fg = colors.peach },
							TSLiteral = { link = "String" },
							TSMath = { fg = colors.blue },
							TSMethod = { fg = colors.green },
							TSMethodCall = { fg = colors.green },
							TSNamespace = { fg = colors.yellow },
							TSNone = { fg = colors.text },
							TSNumber = { fg = colors.mauve },
							TSOperator = { fg = colors.peach },
							TSParameter = { fg = colors.text },
							TSParameterReference = { fg = colors.text },
							TSPreProc = { link = "PreProc" },
							TSProperty = { fg = colors.blue },
							TSPunctBracket = { fg = colors.text },
							TSPunctDelimiter = { link = "Delimiter" },
							TSPunctSpecial = { fg = colors.blue },
							TSRepeat = { fg = colors.red },
							TSStorageClass = { fg = colors.peach },
							TSStorageClassLifetime = { fg = colors.peach },
							TSStrike = { fg = colors.subtext1 },
							TSString = { fg = colors.teal },
							TSStringEscape = { fg = colors.green },
							TSStringRegex = { fg = colors.green },
							TSStringSpecial = { link = "SpecialChar" },
							TSSymbol = { fg = colors.text },
							TSTag = { fg = colors.peach },
							TSTagAttribute = { fg = colors.green },
							TSTagDelimiter = { fg = colors.green },
							TSText = { fg = colors.green },
							TSTextReference = { link = "Constant" },
							TSTitle = { link = "Title" },
							TSTodo = { link = "Todo" },
							TSType = { fg = colors.yellow, style = { "bold" } },
							TSTypeBuiltin = { fg = colors.yellow, style = { "bold" } },
							TSTypeDefinition = { fg = colors.yellow, style = { "bold" } },
							TSTypeQualifier = { fg = colors.peach, style = { "bold" } },
							TSURI = { fg = colors.blue },
							TSVariable = { fg = colors.text },
							TSVariableBuiltin = { fg = colors.mauve },

							["@annotation"] = { link = "TSAnnotation" },
							["@attribute"] = { link = "TSAttribute" },
							["@boolean"] = { link = "TSBoolean" },
							["@character"] = { link = "TSCharacter" },
							["@character.special"] = { link = "TSCharacterSpecial" },
							["@comment"] = { link = "TSComment" },
							["@conceal"] = { link = "Grey" },
							["@conditional"] = { link = "TSConditional" },
							["@constant"] = { link = "TSConstant" },
							["@constant.builtin"] = { link = "TSConstBuiltin" },
							["@constant.macro"] = { link = "TSConstMacro" },
							["@constructor"] = { link = "TSConstructor" },
							["@debug"] = { link = "TSDebug" },
							["@define"] = { link = "TSDefine" },
							["@error"] = { link = "TSError" },
							["@exception"] = { link = "TSException" },
							["@field"] = { link = "TSField" },
							["@float"] = { link = "TSFloat" },
							["@function"] = { link = "TSFunction" },
							["@function.builtin"] = { link = "TSFuncBuiltin" },
							["@function.call"] = { link = "TSFunctionCall" },
							["@function.macro"] = { link = "TSFuncMacro" },
							["@include"] = { link = "TSInclude" },
							["@keyword"] = { link = "TSKeyword" },
							["@keyword.function"] = { link = "TSKeywordFunction" },
							["@keyword.operator"] = { link = "TSKeywordOperator" },
							["@keyword.return"] = { link = "TSKeywordReturn" },
							["@label"] = { link = "TSLabel" },
							["@math"] = { link = "TSMath" },
							["@method"] = { link = "TSMethod" },
							["@method.call"] = { link = "TSMethodCall" },
							["@namespace"] = { link = "TSNamespace" },
							["@none"] = { link = "TSNone" },
							["@number"] = { link = "TSNumber" },
							["@operator"] = { link = "TSOperator" },
							["@parameter"] = { link = "TSParameter" },
							["@parameter.reference"] = { link = "TSParameterReference" },
							["@preproc"] = { link = "TSPreProc" },
							["@property"] = { link = "TSProperty" },
							["@punctuation.bracket"] = { link = "TSPunctBracket" },
							["@punctuation.delimiter"] = { link = "TSPunctDelimiter" },
							["@punctuation.special"] = { link = "TSPunctSpecial" },
							["@repeat"] = { link = "TSRepeat" },
							["@storageclass"] = { link = "TSStorageClass" },
							["@storageclass.lifetime"] = { link = "TSStorageClassLifetime" },
							["@strike"] = { link = "TSStrike" },
							["@string"] = { link = "TSString" },
							["@string.escape"] = { link = "TSStringEscape" },
							["@string.regex"] = { link = "TSStringRegex" },
							["@string.special"] = { link = "TSStringSpecial" },
							["@symbol"] = { link = "TSSymbol" },
							["@tag"] = { link = "TSTag" },
							["@tag.attribute"] = { link = "TSTagAttribute" },
							["@tag.delimiter"] = { link = "TSTagDelimiter" },
							["@text"] = { link = "TSText" },
							["@text.danger"] = { link = "TSDanger" },
							["@text.diff.add"] = { link = "diffAdded" },
							["@text.diff.delete"] = { link = "diffRemoved" },
							["@text.emphasis"] = { link = "TSEmphasis" },
							["@text.environment"] = { link = "TSEnvironment" },
							["@text.environment.name"] = { link = "TSEnvironmentName" },
							["@text.literal"] = { link = "TSLiteral" },
							["@text.math"] = { link = "TSMath" },
							["@text.note"] = { link = "TSNote" },
							["@text.reference"] = { link = "TSTextReference" },
							["@text.strike"] = { link = "TSStrike" },
							["@text.strong"] = { link = "TSStrong" },
							["@text.title"] = { link = "TSTitle" },
							["@text.todo"] = { link = "TSTodo" },
							["@text.todo.checked"] = { link = "Green" },
							["@text.todo.unchecked"] = { link = "Ignore" },
							["@text.underline"] = { link = "TSUnderline" },
							["@text.uri"] = { link = "TSURI" },
							["@text.warning"] = { link = "TSWarning" },
							["@todo"] = { link = "TSTodo" },
							["@type"] = { link = "TSType" },
							["@type.builtin"] = { link = "TSTypeBuiltin" },
							["@type.definition"] = { link = "TSTypeDefinition" },
							["@type.qualifier"] = { link = "TSTypeQualifier" },
							["@uri"] = { link = "TSURI" },
							["@variable"] = { link = "TSVariable" },
							["@variable.builtin"] = { link = "TSVariableBuiltin" },

							["@lsp.type.class"] = { link = "TSType" },
							["@lsp.type.comment"] = { link = "TSComment" },
							["@lsp.type.decorator"] = { link = "TSFunction" },
							["@lsp.type.enum"] = { link = "TSType" },
							["@lsp.type.enumMember"] = { link = "TSProperty" },
							["@lsp.type.events"] = { link = "TSLabel" },
							["@lsp.type.function"] = { link = "TSFunction" },
							["@lsp.type.interface"] = { link = "TSType" },
							["@lsp.type.keyword"] = { link = "TSKeyword" },
							["@lsp.type.macro"] = { link = "TSConstMacro" },
							["@lsp.type.method"] = { link = "TSMethod" },
							["@lsp.type.modifier"] = { link = "TSTypeQualifier" },
							["@lsp.type.namespace"] = { link = "TSNamespace" },
							["@lsp.type.number"] = { link = "TSNumber" },
							["@lsp.type.operator"] = { link = "TSOperator" },
							["@lsp.type.parameter"] = { link = "TSParameter" },
							["@lsp.type.property"] = { link = "TSProperty" },
							["@lsp.type.regexp"] = { link = "TSStringRegex" },
							["@lsp.type.string"] = { link = "TSString" },
							["@lsp.type.struct"] = { link = "TSType" },
							["@lsp.type.type"] = { link = "TSType" },
							["@lsp.type.typeParameter"] = { link = "TSTypeDefinition" },
							["@lsp.type.variable"] = { link = "TSVariable" },
						}
					end,
					latte = function(colors)
						return {
							IblIndent = { fg = colors.mantle },
							IblScope = { fg = colors.surface1 },

							LineNr = { fg = colors.surface1 },
						}
					end,
				},
			})
			vim.api.nvim_set_hl(0, "NavicIconsOperator", { default = true, bg = "none", fg = "#eedaad" })
			vim.api.nvim_set_hl(0, "NavicText", { default = true, bg = "none", fg = "#eedaad" })
			vim.api.nvim_set_hl(0, "NavicSeparator", { default = true, bg = "none", fg = "#eedaad" })
			--
			vim.api.nvim_command("colorscheme catppuccin")
		end,
	},
	{
		"neanias/everforest-nvim",
		enabled = false,
		priority = 1000,
		lazy = false,
		config = function()
			vim.g.everforest_background = "hard"
			vim.g.everforest_enable_italic = 1
			vim.g.everforest_disable_italic_comment = 0
			vim.g.everforest_diagnostic_text_highlight = 1
			vim.g.everforest_diagnostic_line_highlight = 1
			vim.g.everforest_diagnostic_virtual_text = "colored"
			vim.g.everforest_diagnostic_signs = "colored"
			vim.g.everforest_cursor_color = 0
			vim.g.everforest_cursor_style = "line"
			vim.g.everforest_better_performance = 1
			vim.g.everforest_transparent_background = 2
			require("everforest").setup({
				transparent_background_level = 2,
			})
			vim.cmd.colorscheme("everforest")
		end,
	},
	{
		"olimorris/onedarkpro.nvim",
		enabled = false,
		lazy = false,
		priority = 1000,
		config = function()
			require("onedarkpro").setup({
				options = {
					transparency = true,
					lualine_transparency = true,
				},
			})
			vim.cmd.colorscheme("onedark_vivid")
		end,
	},
	{
		"navarasu/onedark.nvim",
		enabled = true,
		lazy = false,
		priority = 1000,
		config = function()
			require("onedark").setup({
				style = "dark",
				transparent = true,
				term_colors = true,
				ending_tildes = false,
				cmp_itemkind_reverse = false,
				code_style = {
					comments = "italic",
					keywords = "italic",
					functions = "none",
					strings = "none",
					variables = "none",
				},
				lualine = {
					transparent = true,
				},
				diagnostics = {
					darker = true,
					undercurl = true,
					background = true,
				},
			})
			require("onedark").load()
		end,
	},
}
