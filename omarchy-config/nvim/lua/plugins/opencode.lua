return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    vim.keymap.set({ "n", "x" }, "<C-a>", function()
      require("opencode").ask("@this: ", { submit = true })
    end, { desc = "Ask opencode" })

    vim.keymap.set({ "n", "x" }, "<C-x>", function()
      -- Wrap in pcall to catch extmark errors from opencode
      local ok, err = pcall(function()
        require("opencode").select()
      end)
      if not ok then
        -- If there's an extmark error in visual mode, exit visual mode and retry
        if err:match("end_col") and vim.fn.mode():match("[vVx\22]") then
          vim.cmd("normal! ")
          vim.schedule(function()
            require("opencode").select()
          end)
        else
          vim.notify("OpenCode error: " .. tostring(err), vim.log.levels.ERROR)
        end
      end
    end, { desc = "Execute opencode action…" })

    vim.keymap.set({ "n", "t" }, "<C-.>", function()
      require("opencode").toggle()
    end, { desc = "Toggle opencode" })
  end,
}
