
return {
  "mhinz/vim-startify",
  config = function()
    vim.g.startify_lists = {
      { type = 'files', header = {'   Recent Files'} },
      { type = 'dir', header = {'   Current Directory'} },
      { type = 'sessions', header = {'   Sessions'} },
    }

    vim.g.startify_custom_header = function()
-- Startify plugin for Neovim
-- A start screen for Neovim with recent files, sessions, and more.

return {        'Welcome to Neovim!',
      }
    end

    vim.g.startify_change_to_dir = 0
  end
}

