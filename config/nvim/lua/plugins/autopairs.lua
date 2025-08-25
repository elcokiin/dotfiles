
-- Autopairs plugin for Neovim
-- Automatically closes brackets, quotes, and other paired characters.

return {
  "windwp/nvim-autopairs",
  config = function()
    require('nvim-autopairs').setup({
      disable_in_macro = false,
      disable_in_visualblock = false,
      ignored_next_char = "[%w%.]"
    })

    local cmp = require('cmp')
    local npairs = require('nvim-autopairs.completion.cmp')
    cmp.event:on('confirm_done', npairs.on_confirm_done())
  end
}
