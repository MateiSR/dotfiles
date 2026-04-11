vim.pack.add({
  'https://codeberg.org/andyg/leap.nvim',
  'https://github.com/tpope/vim-repeat',
})

vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)")
