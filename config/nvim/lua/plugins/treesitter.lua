
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate", -- en lazy.nvim se usa "build" en vez de "run"
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

