local km = vim.keymap
local wk = require("which-key")
local opts = { noremap = true, silent = true }

-- debugging
km.set("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", opts)
km.set("n", "<F6>", "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>", opts)
km.set("n", "<F9>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
km.set("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", opts)
km.set("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", opts)
km.set("n", "<F8>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
km.set("n", "<F12>", function()
  vim.lsp.buf.definition()
end, { noremap = true, silent = true, desc = "Go to definition" })

-- -- leader menu
-- debugging
km.set("n", "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", { desc = "Open Debug REPL" })
km.set("n", "<leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", { desc = "Run Last Debugging Session" })
km.set("n", "<leader>dd", "<Cmd>lua require'dap'.continue()<CR>", { desc = "Start/Continue Debugging" })
km.set(
  "n",
  "<leader>dt",
  "<Cmd>lua require('neotest').run.run({strategy = 'dap'})<CR>",
  { noremap = true, silent = true, desc = "debug nearest test" }
)
wk.add({
  {
    "<leader>dd",
    ":lua require'dap'.continue()<CR>",
    desc = "Start debugging",
    icon = "▶",
  },
})
