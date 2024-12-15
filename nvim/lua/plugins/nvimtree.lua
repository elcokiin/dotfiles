
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

