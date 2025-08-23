local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Notifications history
map("n", "<leader>nh", function()
  require("snacks").notify.history()
end, vim.tbl_extend("force", opts, { desc = "Notifications history" }))

-- Scratch notes (toggle)
map("n", "<leader>ss", function()
  local scratch = require("snacks").scratch
  if scratch.is_open() then
    scratch.close()
  else
    scratch.open()
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle scratch buffer" }))

-- Git browse current file
map("n", "<leader>gb", function()
  require("snacks").gitbrowse.open()
end, vim.tbl_extend("force", opts, { desc = "Open file in git provider" }))

