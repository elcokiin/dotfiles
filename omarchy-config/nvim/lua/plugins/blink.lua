return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        menu = {
          border = "rounded",
        },
        documentation = {
          window = {
            border = "rounded",
          },
        },
      },
      keymap = {
        preset = "enter",
        ["<C-k>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-j>"] = { "select_next", "snippet_forward", "fallback" },
        ["<Tab>"] = {
          LazyVim.cmp.map({ "snippet_forward", "ai_accept" }),
          "fallback",
        },
      },
    },
  },
}
