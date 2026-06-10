
local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- General ask
map("n", "<C-a>", function()
  require("opencode").ask()
end, vim.tbl_extend("force", opts, { desc = "Ask Opencode" }))

-- Ask about cursor
map("n", "<C-S-a>", function()
  require("opencode").ask("@cursor: ")
end, vim.tbl_extend("force", opts, { desc = "Ask about cursor" }))

-- Ask about selection
map("v", "<C-a>", function()
  require("opencode").ask("@selection: ")
end, vim.tbl_extend("force", opts, { desc = "Ask about selection" }))

-- Toggle integrated terminal
map({ "n", "t" }, "<C-o>", function()
  require("opencode").toggle()
end, vim.tbl_extend("force", opts, { desc = "Toggle Opencode terminal" }))

-- Copy last message
map("t", "<C-S-c>", function()
  require("opencode").command("messages_copy")
end, vim.tbl_extend("force", opts, { desc = "Copy last message" }))

