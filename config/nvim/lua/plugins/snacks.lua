
return {
  "folke/snacks.nvim",
  opts = {
    -- Required for opencode.nvim
    input = {
      enabled = true,
      border = "rounded",
      prompt = "❯ ",
    },
    -- Pretty notifications (notifier + notify)
    notify = {
      enabled = true,
      timeout = 5000,
      stages = "fade_in_slide_out",
      border = "single",
      position = "bottom_right",
    },
    -- Open code in repo (GitHub, GitLab, etc.)
    gitbrowse = {
      enabled = true,
      provider = "github",
      -- domain = "github.com", -- Use if self-hosted
    },
    -- Smooth animations & scrolling
    animate = {
      enabled = true,
      scroll = {
        enabled = true,
        timing = 150,
        easing = "quadratic",
      },
    },
    -- Persistent scratch buffer
    scratch = {
      enabled = true,
      file = vim.fn.stdpath("data") .. "/snacks_scratch.md",
      syntax = "markdown",
      open_on_startup = false,
    },
  },
}

