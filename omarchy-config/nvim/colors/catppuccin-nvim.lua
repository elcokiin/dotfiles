-- Omarchy's catppuccin theme resolves the colorscheme as "catppuccin-nvim",
-- but modern catppuccin.nvim (>= 1.0) registers `catppuccin` (and flavour
-- variants) instead. Provide the legacy name as an alias so both the initial
-- load and the theme hot-reloader resolve cleanly.
require("catppuccin").load()