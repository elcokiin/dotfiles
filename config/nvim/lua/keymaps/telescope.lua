
local map = vim.keymap.set
local opts = { noremap = true, silent = true }
local builtin = require("telescope.builtin")

-- Search inside workspace content (like VSCode search)
map("n", "<C-p>", builtin.live_grep, vim.tbl_extend("force", opts, { desc = "Search in workspace" }))

-- Find files in project
map("n", "<C-S-p>", builtin.find_files, vim.tbl_extend("force", opts, { desc = "Find files" }))


