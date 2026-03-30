-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.opt.number = true
vim.opt.relativenumber = true
-- vim.opt.statuscolumn = "%s %= %{v:relnum} %{v:lnum} %C " -- Show both relative and absolute line numbers
vim.opt.statuscolumn = "%s %= %{v:relnum ? v:relnum : v:lnum} %C " -- Show relative line numbers, but absolute for the current line
vim.opt.foldlevel = 99 -- Close all folds below level 1
vim.opt.foldcolumn = "1" -- Optional: shows the fold column
vim.opt.fillchars = {
  foldopen = "⌄",
  foldclose = ">",
  foldsep = "|",
  fold = " ",
}
