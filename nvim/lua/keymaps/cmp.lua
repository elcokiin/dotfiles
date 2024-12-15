
local cmp = require('cmp')

local cmp = {
  ['<C-n>'] = cmp.mapping.select_next_item(),
  ['<C-p>'] = cmp.mapping.select_prev_item(),
  ['<C-d>'] = cmp.mapping.scroll_docs(-4),
  ['<C-u>'] = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
}

return cmp 
