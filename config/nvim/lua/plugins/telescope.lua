
return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" }, 
  opts = {
    defaults = {
      prompt_prefix = "❯ ",
      selection_caret = "➤ ",
      sorting_strategy = "ascending",
      layout_config = {
        horizontal = { preview_width = 0.6 },
      },
      file_ignore_patterns = { "node_modules", ".git/" },
    },
    pickers = {
      find_files = {
        hidden = true, 
      },
      live_grep = {
        only_sort_text = true,
      },
    },
  },
}
