vim.pack.add({
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mason-org/mason-lspconfig.nvim",
	"https://github.com/neovim/nvim-lspconfig",
})

local servers = {
	"lua_ls",
	"ts_ls",
	"clangd",
	"pyright",
	"rust_analyzer",
	"biome",
	"html",
	"bashls",
}

require("mason").setup()
require("mason-lspconfig").setup({ ensure_installed = servers })

local capabilities = require("blink.cmp").get_lsp_capabilities()
for _, server in ipairs(servers) do
	vim.lsp.config(server, { capabilities = capabilities })
end
vim.lsp.enable(servers)

vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})

vim.api.nvim_create_autocmd("CursorHold", {
	callback = function()
		vim.diagnostic.open_float(nil, {
			focusable = false,
			close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
			border = "rounded",
			source = "always",
			prefix = " ",
			scope = "cursor",
		})
	end,
})
