return {
  {
    "glacambre/firenvim",
    build = ":call firenvim#install(0)",
    cond = not not vim.g.started_by_firenvim,
    config = function()
      local vim_g = vim.g
      -- Basic Firenvim settings
      vim_g.firenvim_config = {
        globalSettings = { alt = "all" },
        localSettings = {
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never", -- standard setting to prevent auto-takeover
          },
        },
      }
      -- Auto-start Firenvim when you press Ctrl+e in a text area
    end,
  },
  -- -----------------------------------------------------------------------
  -- DISABLE UI PLUGINS IN BROWSER
  -- -----------------------------------------------------------------------
  -- Firenvim windows are too small for fancy UI.
  -- We disable Noice, Lualine, and Bufferline when in browser.
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      -- Disable noice if inside Firenvim
      if vim.g.started_by_firenvim then
        opts.enabled = false
      end
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      if vim.g.started_by_firenvim then
        opts.options = opts.options or {}
        opts.options.disabled_filetypes = { "firenvim" }
        -- Also manually disable it just in case
        require("lualine").hide()
      end
    end,
  },
}
