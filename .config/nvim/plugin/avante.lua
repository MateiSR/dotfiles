vim.pack.add({
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/MunifTanjim/nui.nvim',
  'https://github.com/nvim-tree/nvim-web-devicons',
  'https://github.com/stevearc/dressing.nvim',
  'https://github.com/MeanderingProgrammer/render-markdown.nvim',
})

vim.pack.add({
  'https://github.com/yetone/avante.nvim',
})

require("avante").setup({
  provider = "copilot",
  mode = "agentic",
  instructions_file = "avante.md",
})
