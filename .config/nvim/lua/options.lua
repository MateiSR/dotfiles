vim.cmd("set expandtab")
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")
vim.g.mapleader = " "

local opt = vim.opt

-- set hybrid line numbers
opt.number = true
opt.relativenumber = true

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

opt.cursorline = true

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- turn off swapfile
opt.swapfile = false

-- set undofile
opt.undofile = true

-- set update time
opt.updatetime = 250

-- required for bufferline
vim.opt.termguicolors = true
