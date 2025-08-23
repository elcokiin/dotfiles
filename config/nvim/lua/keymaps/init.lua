
require("keymaps.cmp")
require("keymaps.gitgutter")
require("keymaps.nvimtree")
require("keymaps.opencode")
require("keymaps.snacks")
require("keymaps.telescope")
--require("keymaps.nerdtree")

vim.g.mapleader = " "
vim.g.maplocalleader = " "

local map = vim.keymap.set

map("n", "<leader>w", ":w<CR>", { desc = "Save File" })
map("n", "<leader>q", ":q<CR>", { desc = "Close File" })
map("n", "<leader>Q", ":q!<CR>", { desc = "Close File without saving", noremap = true } )
map("n", "<leader>W", ":w<CR>:q<CR>", { desc = "Close File without saving",  noremap = true } )

map("n", "<C-h>", "<C-w>h", { noremap = true })
map("n", "<C-l>", "<C-w>l", { noremap = true })

