# Agent Guidelines for Neovim Config

## Project Overview
LazyVim-based Neovim configuration in Lua. Plugin definitions in `lua/plugins/`, configs in `lua/config/`.

## Formatting & Linting
- Format Lua: `stylua .` (config: stylua.toml - 2 spaces, 120 columns)
- No test suite (config files don't require tests)
- LSP diagnostics ignore: `missing-parameter` (.luarc.json)

## Code Style
- **Indentation**: 2 spaces (never tabs)
- **Imports**: Use `require()` at function scope when needed, top-level for config modules
- **Plugin structure**: Return tables with plugin specs, use `opts` for simple configs, `config` function for complex setup
- **Naming**: snake_case for variables/functions, match LazyVim conventions
- **Comments**: Brief comments above complex logic, reference upstream LazyVim docs when relevant
- **Error handling**: Use `vim.notify()` for user feedback, check conditions with `if` before operations
- **Functions**: Prefer anonymous functions in keymaps/autocmds, extract complex logic to named functions
- **Tables**: Trailing commas for multi-line tables, inline for single-line

## Key Patterns
- Keymaps: Use `vim.keymap.set()` with descriptive `desc` field
- LSP keymaps: Define in `opts.servers['*'].keys` for proper LSP attach timing
- LSP handlers: Use `vim.lsp.util.jump_to_location()` for definition/reference jumping
- Options: Set via `vim.opt.*` in options.lua
- Autocmds: Use `vim.api.nvim_create_autocmd()` with callback functions
- Plugin dependencies: Declare explicitly in plugin spec
