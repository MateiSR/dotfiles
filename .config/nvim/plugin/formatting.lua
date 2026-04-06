vim.pack.add({
	"https://github.com/stevearc/conform.nvim",
})

require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "isort", "black" },
		c = { "clang-format" },
		cpp = { "clang-format" },
		javascript = { "biome" },
		typescript = { "biome" },
		javascriptreact = { "biome" },
		typescriptreact = { "biome" },
		json = { "biome" },
		css = { "prettier" },
		html = { "prettier" },
		yaml = { "prettier" },
		markdown = { "prettier" },
		rust = { "rustfmt" },
		bash = { "shfmt" },
		sh = { "shfmt" },
	},
})

vim.keymap.set("n", "<leader>f", function()
	require("conform").format({ lsp_fallback = true })
end)
