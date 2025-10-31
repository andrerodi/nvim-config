local km = vim.keymap
local wk = require("which-key")

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
