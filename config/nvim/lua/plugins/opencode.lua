return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    "folke/snacks.nvim", -- Required for prompts
  },
  ---@type opencode.Opts
  opts = {
    tmux_target = "Opencode", -- Tmux window name where Opencode runs
    auto_context = true,      -- Automatically injects context like @file, @selection, etc.
    -- prompt_prefix = "> ",  -- Optional: custom prompt prefix
  },
  config = function(_, opts)
    require("opencode").setup(opts)
  end,
}

