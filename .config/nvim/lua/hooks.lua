if name == "nvim-treesitter" and (kind == "install" or kind == "update") then
	if not ev.data.active then
		vim.cmd.packadd("nvim-treesitter")
	end
	vim.cmd("TSUpdate")
end

if name == "avante.nvim" and (kind == "install" or kind == "update") then
	if not ev.data.active then
		vim.cmd.packadd("avante.nvim")
	end
	vim.system({ "make" }, { cwd = ev.data.path })
end
