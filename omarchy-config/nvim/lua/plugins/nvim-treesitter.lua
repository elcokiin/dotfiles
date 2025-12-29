return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false,
  priority = 1000,
  opts = {
    ensure_installed = {
      "typescript",
      "tsx",
      "jsx",
      "javascript",
      "lua",
      "json",
      "astro",
      "html",
      "css",
    },
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = { enable = true },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
}
