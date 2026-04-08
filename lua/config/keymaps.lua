-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

require("which-key").add({
  { "<leader>z", group = "fold", icon = "›" },
})

-- Fold level keymaps
map("n", "<leader>z0", function()
  vim.opt.foldlevel = 0
end, { desc = "fold level 0" })
map("n", "<leader>z1", function()
  vim.opt.foldlevel = 1
end, { desc = "fold level 1" })
map("n", "<leader>z2", function()
  vim.opt.foldlevel = 2
end, { desc = "fold level 2" })
map("n", "<leader>z3", function()
  vim.opt.foldlevel = 3
end, { desc = "fold level 3" })
map("n", "<leader>zo", function()
  vim.opt.foldlevel = 99
end, { desc = "fold open all" })

-- Move selected lines down
map("v", "<A-Down>", ":m '>+1<CR>gv=gv")
-- Move selected lines up
map("v", "<A-Up>", ":m '<-2<CR>gv=gv")
