-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local api = vim.api

api.nvim_create_autocmd({ "UIEnter" }, {
  callback = function(event)
    local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
    if client ~= nil and client.name == "Firenvim" then
      vim.o.guifont = "JetBrainsMono Nerd Font:h14"
      vim.o.relativenumber = false
      vim.o.wrap = true
      vim.o.laststatus = 0
      vim.o.showtabline = 0
    end
  end,
})

-- Configuración para effect-tsgo usando bunx
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact" },
  callback = function()
    vim.lsp.start({
      name = "effect-tsgo",
      -- Cambiado a bunx para un inicio casi instantáneo
      cmd = { "bunx", "typescript-language-server", "--stdio" },
      root_dir = vim.fs.root(0, { "package.json", "tsconfig.json", ".git" }),
    })
  end,
})
