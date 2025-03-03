vim.keymap.set("n", "<C-s>", ":up<CR>", {})
vim.keymap.set("n", "<leader>h", ":terminal<CR>", {})
-- bind quickfix
vim.keymap.set("n", "<leader>q", ":copen<CR>", {})
-- bind qf close
vim.keymap.set("n", "<leader>Q", ":cclose<CR>", {})
-- split window
vim.keymap.set("n", "<leader>sh", ":split<CR>", {})
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", {})
-- move between windows
vim.keymap.set("n", "<C-h>", "<C-w>h", {})
vim.keymap.set("n", "<C-j>", "<C-w>j", {})
vim.keymap.set("n", "<C-k>", "<C-w>k", {})
vim.keymap.set("n", "<C-l>", "<C-w>l", {})
-- close current split
vim.keymap.set("n", "<leader>sq", "<C-w>q", {})
-- open terminal
vim.keymap.set("n", "<leader>tt", ":terminal<CR>", {})
-- close terminal
vim.keymap.set("t", "<leader>tq", "<C-\\><C-n>:q<CR>", {})
-- vim.keymap.set("n", "<leader>tq", "i<C-d><CR><CR>", {})
-- open terminal in split
vim.keymap.set("n", "<leader>ts", ":split<CR>:terminal<CR>", {})
-- Move selected lines down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
-- Move selected lines up in visual mode
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
-- Join the current line with the next line and keep the cursor in place
vim.keymap.set("n", "J", "mzJ`z")
-- Scroll down by half a screen and center the cursor
vim.keymap.set("n", "<C-d>", "<C-d>zz")
-- Scroll up by half a screen and center the cursor
vim.keymap.set("n", "<C-u>", "<C-u>zz")
-- Move to the next search result and center the cursor
vim.keymap.set("n", "n", "nzzzv", { noremap = true })
-- Move to the previous search result and center the cursor
vim.keymap.set("n", "N", "Nzzzv", { noremap = true })
-- Disable the 'Q' key in normal mode (prevents entering Ex mode)
vim.keymap.set("n", "Q", "<nop>")
-- Easy redo
vim.keymap.set("n", "U", "<C-r>")
-- Move to the beginning of the line
vim.keymap.set("n", "H", "^")
-- Move to the end of the line
vim.keymap.set("n", "L", "$")
-- escape from insert mode
vim.keymap.set("i", "jj", "<Esc>")
-- open copilot chat
vim.keymap.set("n", "<leader>cc", ":CopilotChatOpen<CR>", {})
