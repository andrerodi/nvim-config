-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local km = vim.keymap
local wk = require("which-key")
local opts = { noremap = true, silent = true }

-- build
km.set("n", "<C-b>", function()
  -- Start from the current file's directory
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end

  -- Search upward for a .csproj file
  local function find_csproj(path)
    local csprojs = vim.fn.globpath(path, "*.csproj", false, true)
    if #csprojs > 0 then
      return path, csprojs[1]
    end
    local parent = vim.fn.fnamemodify(path, ":h")
    if parent == path then
      return nil -- reached root
    end
    return find_csproj(parent)
  end

  local project_dir, project_file = find_csproj(dir)
  if not project_dir then
    print("❌ No .csproj found in current or parent directories.")
    return
  end

  print("📦 Building: " .. project_file)

  -- Run dotnet build
  vim.fn.jobstart({ "dotnet", "build" }, {
    cwd = project_dir,
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data)
      if data then
        print(table.concat(data, "\n"))
      end
    end,
    on_stderr = function(_, data)
      if data then
        print(table.concat(data, "\n"))
      end
    end,
  })
end, { desc = "Build .NET project (search upwards for .csproj)" })

-- c# keymappings
km.set("n", "<C-.>", vim.lsp.buf.code_action, { desc = "Code actions (like Add using)" })
-- inside your keymaps setup
km.set("n", "<C-r><C-r>", "<cmd>lua vim.lsp.buf.rename()<CR>", { noremap = true, silent = true })

-- Navigate between buffers with Alt + Up/Down
km.set("n", "<A-e>", ":Neotree focus<CR>", { desc = "Focus solution tree" })
km.set("n", "<A-Up>", ":bnext<CR>", { desc = "Next buffer" })
km.set("n", "<A-Down>", ":bprevious<CR>", { desc = "Previous buffer" })
km.set("n", "<A-w>", ":bp | bd #<CR>", { desc = "Close current buffer only" })

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
-- fzf-lua
-- km.set("n", "<leader>p", require("fzf-lua").files, { desc = "FZF Files" })
wk.add({
  {
    "<leader>fy",
    require("fzf-lua").files,
    desc = "FZF Files",
    icon = "🔎",
  },
})

-- nuget
wk.add({
  { "<leader>N", group = "NuGet", icon = "" },
  {
    -- List installed packages
    "<leader>Ni",
    ":lua require('../nuget-explorer/nuget-explorer').show_installed()<CR>",
    desc = "Installed NuGet packages",
  },
  {
    -- Search and install online packages
    "<leader>Ns",
    ":lua require('../nuget-explorer/nuget-explorer').search_online()<CR>",
    desc = "Search NuGet.org",
  },
})

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

-- git
-- add file
km.set("n", "<leader>ga", function()
  local file = vim.fn.expand("%:p") -- absolute path of current file
  if file == "" then
    vim.notify("⚠️ No file open to add to Git", vim.log.levels.WARN)
    return
  end

  -- Detect Git root from file location
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.fnamemodify(file, ":h") .. " rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then
    vim.notify("❌ Not inside a Git repository", vim.log.levels.ERROR)
    return
  end
  git_root = vim.fn.trim(git_root)

  -- If inside .git folder, move up one level
  if git_root:match("%.git$") then
    git_root = vim.fn.fnamemodify(git_root, ":h")
  end

  if vim.fn.isdirectory(git_root) == 0 then
    vim.notify("❌ Invalid Git root: " .. git_root, vim.log.levels.ERROR)
    return
  end

  -- Async git add using jobstart
  vim.fn.jobstart({ "git", "add", file }, {
    cwd = git_root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        vim.schedule(function()
          vim.notify(table.concat(data, "\n"), vim.log.levels.INFO)
        end)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.schedule(function()
          vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
        end)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✅ Added to Git: " .. vim.fn.fnamemodify(file, ":."), vim.log.levels.INFO)
      else
        vim.notify("❌ Failed to add file to Git", vim.log.levels.ERROR)
      end
    end,
  })
end, { desc = "Add current file to Git" })

-- unstage/reset file
km.set("n", "<leader>gu", function()
  local file = vim.fn.expand("%:p") -- absolute path of current file
  if file == "" then
    vim.notify("⚠️ No file open to unstage", vim.log.levels.WARN)
    return
  end

  -- Detect Git root from file location
  local git_root = vim.fn.systemlist("git -C " .. vim.fn.fnamemodify(file, ":h") .. " rev-parse --show-toplevel")[1]
  if not git_root or git_root == "" then
    vim.notify("❌ Not inside a Git repository", vim.log.levels.ERROR)
    return
  end
  git_root = vim.fn.trim(git_root)

  -- If inside .git folder, move up one level
  if git_root:match("%.git$") then
    git_root = vim.fn.fnamemodify(git_root, ":h")
  end

  if vim.fn.isdirectory(git_root) == 0 then
    vim.notify("❌ Invalid Git root: " .. git_root, vim.log.levels.ERROR)
    return
  end

  -- Async git reset (unstage) using jobstart
  vim.fn.jobstart({ "git", "reset", file }, {
    cwd = git_root,
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data and #data > 0 then
        vim.schedule(function()
          vim.notify(table.concat(data, "\n"), vim.log.levels.INFO)
        end)
      end
    end,
    on_stderr = function(_, data)
      if data and #data > 0 then
        vim.schedule(function()
          vim.notify(table.concat(data, "\n"), vim.log.levels.ERROR)
        end)
      end
    end,
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("✅ Unstaged from Git: " .. vim.fn.fnamemodify(file, ":."), vim.log.levels.INFO)
      else
        vim.notify("❌ Failed to unstage file from Git", vim.log.levels.ERROR)
      end
    end,
  })
end, { desc = "Unstage current file from Git" })
