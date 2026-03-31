return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require("blame").setup()
      require("config.git-blame")
    end,
    opts = {
      blame_options = { "-w" },
    },
  },
}
