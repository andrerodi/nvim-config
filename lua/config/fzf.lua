local wk = require("which-key")

-- fzf-lua
wk.add({
  {
    "<leader>fy",
    require("fzf-lua").files,
    desc = "FZF Files",
    icon = "🔎",
  },
})
