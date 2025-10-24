vim.lsp.config("roslyn", {})

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        roslyn = {
          settings = {
            ["csharp"] = {
              inlayHints = { enable = true },
            },
          },
        },
      },
    },
  },
}
