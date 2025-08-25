
-- GitGutter plugin for Neovim
-- Shows git diff markers in the sign column.

return {
  "airblade/vim-gitgutter",
  config = function()
    vim.g.gitgutter_enabled = 1
    vim.g.gitgutter_map_keys = 0
  end
}
