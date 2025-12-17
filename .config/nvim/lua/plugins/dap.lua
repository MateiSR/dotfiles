return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"saghen/blink.compat",
		"rcarriga/cmp-dap",
		"nvim-neotest/nvim-nio",
		"rcarriga/nvim-dap-ui",
		"theHamsta/nvim-dap-virtual-text",
	},
	config = function()
		require("nvim-dap-virtual-text").setup()
		local dap, dapui = require("dap"), require("dapui")
		dap.adapters.gdb = {
			type = "executable",
			command = "gdb",
			args = { "-i", "dap" },
		}

		dap.adapters.lldb = {
			type = "executable",
			command = "/usr/bin/lldb-dap",
			name = "lldb",
		}

		require("blink.cmp").setup({
			sources = {
				default = { "lsp", "path", "snippets", "buffer" },
				per_filetype = {
					["dap-repl"] = { "dap" },
					["dapui_watches"] = { "dap" },
					["dapui_hover"] = { "dap" },
				},
				providers = {
					dap = {
						name = "DAP",
						module = "blink.compat.source",
						score_offset = 100,
						opts = {},
					},
				},
			},
		})

		local basic_gdb_configuration = {
			--name = "debug",
			type = "gdb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopAtBeginningOfMainSubprogram = false,
			args = function()
				local input = vim.fn.input("Arguments: ")
				if input == "" then
					return {}
				end
				return vim.split(input, " ")
			end,
			setupCommands = {
				{
					text = "-enable-pretty-printing",
					description = "enable pretty printing",
					ignoreFailures = false,
				},
			},
		}

		local basic_lldb_configuration = {
			--name = "debug",
			type = "lldb",
			request = "launch",
			initCommands = function()
				-- Find out where to look for the pretty printer Python module
				local rustc_sysroot = vim.fn.trim(vim.fn.system("rustc --print sysroot"))

				local script_import = 'command script import "' .. rustc_sysroot .. '/lib/rustlib/etc/lldb_lookup.py"'
				local commands_file = rustc_sysroot .. "/lib/rustlib/etc/lldb_commands"

				local commands = {}
				local file = io.open(commands_file, "r")
				if file then
					for line in file:lines() do
						table.insert(commands, line)
					end
					file:close()
				end
				table.insert(commands, 1, script_import)

				return commands
			end,
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
			end,
			cwd = "${workspaceFolder}",
			stopAtBeginningOfMainSubprogram = false,
			args = function()
				local input = vim.fn.input("Arguments: ")
				if input == "" then
					return {}
				end
				return vim.split(input, " ")
			end,
		}

		local c_gdb_config = basic_gdb_configuration
		c_gdb_config.name = "debug c"
		local cpp_gdb_config = basic_gdb_configuration
		cpp_gdb_config.name = "debug cpp"
		local rust_lldb_config = basic_lldb_configuration
		rust_lldb_config.name = "debug rust (lldb)"

		dap.configurations = {
			c = {
				c_gdb_config,
			},
			cpp = {
				cpp_gdb_config,
			},
			rust = {
				rust_lldb_config,
			},
		}

		dapui.setup()
		local open_dapui = function()
			dapui.open()
			-- close neotree
			-- vim.cmd(":Neotree filesystem close<CR>")
		end
		local close_dapui = function()
			dapui.close()
			-- reopen neotree
			-- vim.cmd(":Neotree filesystem reveal left<CR>")
		end
		dap.listeners.before.attach.dapui_config = open_dapui
		dap.listeners.before.launch.dapui_config = open_dapui
		dap.listeners.before.event_terminated.dapui_config = close_dapui
		dap.listeners.before.event_exited.dapui_config = close_dapui

		vim.keymap.set("n", "<Leader>b", vim.cmd.DapToggleBreakpoint)
		vim.keymap.set("n", "<F1>", function()
			vim.cmd.DapContinue()
			vim.cmd.Neotree("toggle")
		end)
		vim.keymap.set("n", "<F2>", vim.cmd.DapStepInto)
		vim.keymap.set("n", "<F3>", vim.cmd.DapStepOver)
		vim.keymap.set("n", "<F4>", vim.cmd.DapStepOut)
		vim.keymap.set("n", "<F5>", vim.cmd.DapTerminate)
	end,
}
