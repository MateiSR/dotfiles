vim.pack.add({
  'https://codeberg.org/andyg/leap.nvim',
  'https://github.com/tpope/vim-repeat',
})

vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)")
vim.keymap.set("n", "S", "<Plug>(leap-from-window)")
