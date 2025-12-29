return {
  -- Disable telescope-ui-select.nvim since we're using dressing.nvim from LazyVim's telescope extra
  {
    "nvim-telescope/telescope-ui-select.nvim",
    enabled = false,
  },
  -- Add custom navigation keymaps to Telescope
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, opts)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      -- Custom action to switch to results window
      local function focus_results(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local results_bufnr = picker.results_bufnr
        local results_winid = vim.fn.bufwinid(results_bufnr)
        if results_winid ~= -1 then
          vim.api.nvim_set_current_win(results_winid)
        end
      end

      -- Custom action to switch to preview window
      local function focus_preview(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        if picker.previewer then
          local preview_winid = picker.previewer.state and picker.previewer.state.winid
          if preview_winid and vim.api.nvim_win_is_valid(preview_winid) then
            vim.api.nvim_set_current_win(preview_winid)
          end
        end
      end

      -- Merge with existing mappings
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        mappings = {
          i = {
            -- Navigation with C-j/C-k (works alongside blink.cmp context-dependent)
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- Switch between results and preview with C-h/C-l
            ["<C-h>"] = focus_results,
            ["<C-l>"] = focus_preview,
          },
          n = {
            -- Navigation with C-j/C-k in normal mode
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
            -- Switch between results and preview with C-h/C-l
            ["<C-h>"] = focus_results,
            ["<C-l>"] = focus_preview,
          },
        },
      })

      return opts
    end,
  },
}
