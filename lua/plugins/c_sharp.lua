return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp",
      },
    },
    config = function()
      require("config.c_sharp")
    end,
  },

  "seblyng/roslyn.nvim",
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  ft = { "cs", "razor" },
  opts = {
    -- your configuration comes here; leave empty for default settings
  },

  {
    "neovim/nvim-lspconfig",
    opts = {
      codelens = {
        enabled = true,
      },
    },
  },
}
