local map = vim.keymap.set

map("n", "<leader>gx", "<cmd>BlameToggle<cr>", { desc = "Toggle git blame" })
map("n", "<leader>gX", "<cmd>BlameToggle virtual<cr>", { desc = "Toggle git blame (virtual)" })
