
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General ask
map("n", "<C-a>", function()
  require("opencode").ask()
end, vim.tbl_extend("force", opts, { desc = "Ask Opencode" }))

-- Ask about cursor
map("n", "<C-b>", function()
  require("opencode").ask("@cursor: ")
end, vim.tbl_extend("force", opts, { desc = "Ask about cursor" }))

-- Ask about selection
map("v", "<S-C-b>", function()
  require("opencode").ask("@selection: ")
end, vim.tbl_extend("force", opts, { desc = "Ask about selection" }))

-- Toggle integrated terminal
map("n", "<C-o>", function()
  require("opencode").toggle()
end, vim.tbl_extend("force", opts, { desc = "Toggle Opencode terminal" }))

-- Copy last message
map("n", "<S-C-c>", function()
  require("opencode").command("messages_copy")
end, vim.tbl_extend("force", opts, { desc = "Copy last message" }))

-- Scroll messages up
map("n", "<S-C-u>", function()
  require("opencode").command("messages_half_page_up")
end, vim.tbl_extend("force", opts, { desc = "Scroll messages up" }))

-- Scroll messages down
map("n", "<S-C-d>", function()
  require("opencode").command("messages_half_page_down")
end, vim.tbl_extend("force", opts, { desc = "Scroll messages down" }))

