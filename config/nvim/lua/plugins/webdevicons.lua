
-- Nvim-Web-Devicons plugin for Neovim
-- Adds file type icons to Neovim.

return {
  "kyazdani42/nvim-web-devicons",
  config = function()
    require'nvim-web-devicons'.setup {
      default = true; 
    }
  end
}
