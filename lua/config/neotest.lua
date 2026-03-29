-- set config BEFORE requiring the adapter
vim.g.neotest_vstest = {
  dap_settings = {
    type = "coreclr", -- matches your nvim-dap.lua adapter registration
  },
  broad_recursive_discovery = false, -- avoid freezing in monorepo
  discovery_directory_filter = function(path)
    return path:match("/%.") -- ignore hidden dirs
  end,
}

require("neotest").setup({
  adapters = {
    require("neotest-vstest"),
  },
})
