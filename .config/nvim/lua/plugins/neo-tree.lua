return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          ".github",
          ".gitignore",
          "package-lock.json",
        },
        never_show = { ".git" },
      },
    },
  },
  config = function()
    vim.keymap.set("n", "<C-n>", function()
      local current_win_id = vim.api.nvim_get_current_win()
      local neotree_win_id = nil
      local neotree_is_focused = false

      -- Iterate through all windows to find a neo-tree window
      for _, win_id in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(win_id) then -- Ensure window is valid
          local buf_id = vim.api.nvim_win_get_buf(win_id)
          if vim.api.nvim_buf_is_valid(buf_id) then -- Ensure buffer is valid
            local buf_ft = vim.api.nvim_buf_get_option(buf_id, "filetype")
            -- Alternative check: buffer name often contains "neo-tree"
            -- local buf_name = vim.api.nvim_buf_get_name(buf_id)

            if buf_ft == "neo-tree" then -- or (buf_name and buf_name:match("neo%-tree"))
              neotree_win_id = win_id -- Found a neo-tree window
              if win_id == current_win_id then
                neotree_is_focused = true
              end
              break -- Assuming one main neo-tree window or acting on the first found
            end
          end
        end
      end

      if neotree_win_id == nil then
        -- Case 1: Neo-tree is not open, so open it (revealing current file is user-friendly).
        vim.cmd("Neotree filesystem reveal left")
      elseif neotree_is_focused then
        -- Case 2: Neo-tree is open and focused, so close it.
        vim.cmd("Neotree close")
      else
        -- Case 3: Neo-tree is open but not in focus, so focus it.
        vim.cmd("Neotree focus")
      end
    end, { desc = "Toggle/Focus Neo-tree", noremap = true, silent = true })

  end,
}
