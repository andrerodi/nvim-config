return {
  {
    "github/copilot.vim",
    event = "VimEnter",
    config = function()
      vim.g.copilot_no_tab_map = true
      -- Require configuration from config file
      require("../config/copilot")
    end,
  },
}
