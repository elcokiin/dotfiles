
-- NvimTree plugin for Neovim
-- A file explorer tree for Neovim.

return {
  "kyazdani42/nvim-tree.lua",
  config = function()
    require('nvim-tree').setup {
      renderer = {
        icons = {
          glyphs = {
            default = '',
            symlink = '',
            folder = {
              arrow_open = '',
              arrow_closed = '',
            },
          },
        },
      },
    }
    require('nvim-web-devicons').setup {
      default = true,
    }
  end
}

