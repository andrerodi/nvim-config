vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-.>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
vim.api.nvim_set_keymap("i", "<C-X>", "copilot#Dismiss()", { silent = true, expr = true })
