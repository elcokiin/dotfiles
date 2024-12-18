
return {
  "nvim-lualine/lualine.nvim",
  requires = { "kyazdani42/nvim-web-devicons" },  -- For the icons 
  config = function()
    require('lualine').setup({
      options = {
        theme = 'dracula',
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' },
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename', 'filesize'},
        lualine_x = {'encoding', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      }
    })
  end
}
