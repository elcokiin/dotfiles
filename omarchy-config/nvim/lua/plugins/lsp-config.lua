return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "prettierd",
        "eslint_d",
        "stylua",
        "clang-format",
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "lua_ls",
        "ts_ls",
        "html",
        "cssls",
        "jsonls",
        "eslint",
        "tailwindcss",
        "clangd",
        "bashls",
        "hyprls",
        "astro",
      },
      automatic_installation = true,
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason-lspconfig.nvim" },
    opts = {
      servers = {
        lua_ls = {},
        ts_ls = {},
        astro = {},
        html = {},
        cssls = {},
        jsonls = {},
        eslint = {},
        tailwindcss = {},
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
          },
        },
        bashls = {},
        hyprls = {},
        -- Override default keymaps for all servers
        ["*"] = {
          keys = {
            -- Custom gd with fallback to grep_string when LSP fails
            {
              "gd",
              function()
                local clients = vim.lsp.get_clients({ bufnr = 0 })
                local word = vim.fn.expand("<cword>")

                local function fallback()
                  require("telescope.builtin").grep_string({
                    search = word,
                    use_regex = false,
                  })
                end

                if #clients == 0 then
                  fallback()
                  return
                end

                local supports_definition = false
                local offset_encoding = "utf-16"
                for _, client in ipairs(clients) do
                  if client.supports_method("textDocument/definition") then
                    supports_definition = true
                    offset_encoding = client.offset_encoding or "utf-16"
                    break
                  end
                end

                if supports_definition then
                  local params = vim.lsp.util.make_position_params(0, offset_encoding)
                  vim.lsp.buf_request(0, "textDocument/definition", params, function(err, result, ctx, config)
                    if result and not vim.tbl_isempty(result) then
                      if vim.islist(result) then
                        vim.lsp.util.jump_to_location(result[1], offset_encoding)
                      else
                        vim.lsp.util.jump_to_location(result, offset_encoding)
                      end
                    else
                      fallback()
                    end
                  end)
                else
                  fallback()
                end
              end,
              desc = "Goto Definition (with fallback)",
              has = "definition",
            },
            -- Keep custom diagnostic keymap
            { "E", vim.diagnostic.open_float, desc = "Show error/warning in a window" },
          },
        },
      },
      diagnostics = {
        virtual_text = {
          spacing = 4,
          prefix = "󰅚 ",
        },
        signs = true,
        underline = true,
        float = {
          focused = false,
          style = "minimal",
          border = "rounded",
          source = true,
          header = "",
          prefix = "",
        },
      },
    },
  },
}
