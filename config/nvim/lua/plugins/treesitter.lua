
-- Nvim-Treesitter plugin for Neovim
-- Provides a Tree-sitter integration for Neovim, enabling better syntax highlighting and indentation.

return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate", 
  config = function()
    require("nvim-treesitter.configs").setup {
      ensure_installed = {
        "lua",
        "python",
        "javascript",
        "typescript",
        "tsx",
        "html",
        "css",
        "bash",
        "json",
        "yaml",
        "markdown",
      },
      highlight = {
        enable = true, -- enable syntax highlighting
      },
      indent = {
        enable = true, -- optional: better indentation
      },
    }
  end,
}

