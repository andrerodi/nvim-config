-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local km = vim.keymap
-- local wk = require("which-key")
-- local opts = { noremap = true, silent = true }

-- inside your keymaps setup
km.set("n", "<C-r><C-r>", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })

-- Navigate between buffers with Alt + Up/Down
km.set("n", "<A-e>", ":Neotree focus<CR>", { desc = "Focus solution tree" })
km.set("n", "<A-w>", ":bp | bd #<CR>", { desc = "Close current buffer only" })
km.set("n", "<A-Up>", ":bnext<CR>", { desc = "Next buffer" })
km.set("n", "<A-Down>", ":bprevious<CR>", { desc = "Previous buffer" })
