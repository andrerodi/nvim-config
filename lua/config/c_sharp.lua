local _ = require("mason.settings").current.install_root_dir

vim.lsp.config("roslyn", {
  choose_target = function(targets)
    -- automatically pick the first .sln file
    for _, target in ipairs(targets) do
      if target:match("%.sln$") then
        return target
      end
    end
  end,
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
    },
  },
})

local map = vim.keymap.set

local function find_csproj(dir)
  local csproj = vim.fn.glob(dir .. "/*.csproj", true, true)
  if #csproj > 0 then
    return csproj[1], dir
  end
  local parent = vim.fn.fnamemodify(dir, ":h")
  if parent == dir then
    return nil, nil
  end
  return find_csproj(parent)
end

local term_buf = nil
local term_win = nil

local function run_dotnet(args)
  local buf_dir = vim.fn.expand("%:p:h")
  local csproj, project_dir = find_csproj(buf_dir)
  if not csproj or not project_dir then
    vim.notify("No .csproj found", vim.log.levels.ERROR)
    return
  end

  local prev_win = vim.api.nvim_get_current_win()

  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
  end
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_buf_delete(term_buf, { force = true })
  end

  term_buf = vim.api.nvim_create_buf(false, true)
  vim.cmd("botright 15split")
  term_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(term_win, term_buf)

  local chan = vim.api.nvim_open_term(term_buf, {})

  local cmd = { "dotnet" }
  for _, arg in ipairs(args) do
    table.insert(cmd, arg)
  end
  table.insert(cmd, project_dir)

  vim.system(cmd, {
    stdout = function(_, data)
      if data then
        vim.schedule(function()
          vim.api.nvim_chan_send(chan, data)
        end)
      end
    end,
    stderr = function(_, data)
      if data then
        vim.schedule(function()
          vim.api.nvim_chan_send(chan, data)
        end)
      end
    end,
  }, function(result)
    vim.schedule(function()
      local label = table.concat(args, " ")
      if result.code == 0 then
        vim.notify("dotnet " .. label .. " succeeded ✓", vim.log.levels.INFO)
      else
        vim.notify("dotnet " .. label .. " failed ✗", vim.log.levels.ERROR)
      end
    end)
  end)

  vim.api.nvim_set_current_win(prev_win)
end

local function scaffold_dotnet(template, name)
  local buf_dir = vim.fn.expand("%:p:h")
  vim.ui.input({ prompt = "Name: ", default = name }, function(input)
    if not input then
      return
    end
    vim.system({ "dotnet", "new", template, "--name", input, "--output", buf_dir }, {}, function(result)
      vim.schedule(function()
        if result.code == 0 then
          vim.notify("Created " .. input .. " ✓", vim.log.levels.INFO)
          vim.cmd("edit " .. buf_dir .. "/" .. input .. ".cs")
        else
          vim.notify("Failed to create " .. input .. "\n" .. (result.stderr or ""), vim.log.levels.ERROR)
        end
      end)
    end)
  end)
end

require("which-key").add({
  { "<leader>Bc", group = "create", icon = "🆕" },
})

map("n", "<leader>Bcc", function()
  scaffold_dotnet("class", "MyClass")
end, { noremap = true, silent = true, desc = "new class" })
map("n", "<leader>Bci", function()
  scaffold_dotnet("interface", "IMyInterface")
end, { noremap = true, silent = true, desc = "new interface" })
map("n", "<leader>Bcr", function()
  scaffold_dotnet("record", "MyRecord")
end, { noremap = true, silent = true, desc = "new record" })
map("n", "<leader>Bcs", function()
  scaffold_dotnet("struct", "MyStruct")
end, { noremap = true, silent = true, desc = "new struct" })

require("which-key").add({
  { "<leader>B", group = ".dotnet", icon = "👾" },
})

map("n", "<leader>Bb", function()
  run_dotnet({ "build" })
end, { noremap = true, silent = true, desc = "dotnet build" })

map("n", "<leader>Bn", function()
  run_dotnet({ "build", "--no-restore" })
end, { noremap = true, silent = true, desc = "dotnet build --no-restore" })

map("n", "<leader>Bc", function()
  run_dotnet({ "clean" })
end, { noremap = true, silent = true, desc = "dotnet clean" })

map("n", "<leader>Br", function()
  run_dotnet({ "run" })
end, { noremap = true, silent = true, desc = "dotnet run" })

map("n", "<leader>Bt", function()
  run_dotnet({ "test" })
end, { noremap = true, silent = true, desc = "dotnet test" })

map("n", "<leader>Bp", function()
  run_dotnet({ "publish", "--configuration", "Release" })
end, { noremap = true, silent = true, desc = "dotnet publish" })
