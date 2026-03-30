-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.statuscolumn = "%s %= %{v:relnum} %{v:lnum} %C "

vim.opt.foldcolumn = "1" -- Optional: shows the fold column
vim.opt.fillchars = {
  foldopen = "⌄",
  foldclose = ">",
  foldsep = " ",
  fold = " ",
}
