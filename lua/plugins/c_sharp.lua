return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "c_sharp",
      },
    },
  },
  "seblyng/roslyn.nvim",
  ---@module 'roslyn.config'
  ---@type RoslynNvimConfig
  ft = { "cs", "razor" },
  opts = {
    -- your configuration comes here; leave empty for default settings
  },
  config = function()
    require("config.c_sharp")
  end,
}
