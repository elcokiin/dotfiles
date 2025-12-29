-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>ww", function()
  vim.cmd.write()
  vim.notify("File saved successfully", vim.log.levels.INFO)
end, {
  silent = true,
  desc = "Save current file",
})

-- Keymap for Competitive Programming (C++)
vim.keymap.set("n", "<leader>r", function()
  vim.cmd("silent! w")

  local file = vim.fn.expand("%")
  local output_name = vim.fn.expand("%:t:r")
  local output_dir = "comp" -- The folder name
  local output_path = output_dir .. "/" .. output_name

  if vim.fn.isdirectory(output_dir) == 0 then
    vim.fn.mkdir(output_dir, "p")
  end

  local compile_cmd = string.format("g++ -O2 -Wall -Wextra -std=c++20 %s -o %s", file, output_path)

  -- To use input.txt, change the end to: .. " < input.txt"
  vim.cmd("split | term " .. compile_cmd .. " && ./" .. output_path)
  vim.cmd("startinsert")
end, { desc = "Compile and Run C++" })
