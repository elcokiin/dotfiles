local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Scratch notes (toggle)
map("n", "<C-s>", function()
  local Snacks = require("snacks")
  local bufnr = vim.fn.bufnr("SnacksScratch")

  if bufnr ~= -1 then
    vim.api.nvim_buf_delete(bufnr, { force = true }) 
  else
    Snacks.scratch.open()
  end
end, vim.tbl_extend("force", opts, { desc = "Toggle scratch buffer" }))

-- Git browse current file
map("n", "<C-g>", function()
  require("snacks").gitbrowse.open()
end, vim.tbl_extend("force", opts, { desc = "Open file in git provider" }))

