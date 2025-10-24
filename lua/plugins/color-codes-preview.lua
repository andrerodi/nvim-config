return {
  "norcalli/nvim-colorizer.lua",
  config = function()
    require("colorizer").setup({
      "*", -- highlight all files
      lua = { mode = "foreground" }, -- for Lua, show colored text in foreground (or background)
    }, {
      RGB = true, -- #RGB hex codes
      RRGGBB = true, -- #RRGGBB hex codes
      names = false, -- disable color names
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      css = false, -- disable CSS
      css_fn = false, -- disable css functions
    })
  end,
}
