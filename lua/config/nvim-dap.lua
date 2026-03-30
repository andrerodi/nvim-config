local dap = require("dap")

local mason_path = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg"

local netcoredbg_adapter = {
  type = "executable",
  command = mason_path,
  args = { "--interpreter=vscode" },
}

dap.adapters.netcoredbg = netcoredbg_adapter -- needed for normal debugging
dap.adapters.coreclr = netcoredbg_adapter -- needed for unit test debugging

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      local buf_path = vim.fn.expand("%:p:h") -- directory of current buffer

      -- walk up to find the nearest .csproj
      local function find_csproj(dir)
        local csproj = vim.fn.glob(dir .. "/*.csproj", true, true)
        if #csproj > 0 then
          return csproj[1], dir
        end
        local parent = vim.fn.fnamemodify(dir, ":h")
        if parent == dir then
          return nil, nil
        end -- reached fs root
        return find_csproj(parent)
      end

      local csproj, project_dir = find_csproj(buf_path)

      if not csproj then
        vim.notify("No .csproj found", vim.log.levels.ERROR)
        return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
      end

      local project_name = vim.fn.fnamemodify(csproj, ":t:r") -- e.g. "AndRod.Core"
      local dll_pattern = project_dir .. "/bin/Debug/**/" .. project_name .. ".dll"
      local dlls = vim.fn.glob(dll_pattern, true, true)

      if #dlls == 1 then
        vim.notify("Debugging: " .. dlls[1], vim.log.levels.INFO)
        return dlls[1]
      elseif #dlls > 1 then
        local choice
        vim.ui.select(dlls, { prompt = "Select DLL:" }, function(c)
          choice = c
        end)
        return choice
      else
        vim.notify("No DLL found for " .. project_name .. ". Did you build?", vim.log.levels.WARN)
        return vim.fn.input("Path to dll: ", project_dir .. "/bin/Debug/", "file")
      end
    end,

    -- justMyCode = false,
    -- stopAtEntry = false,
    -- -- program = function()
    -- --   -- todo: request input from ui
    -- --   return "/path/to/your.dll"
    -- -- end,
    -- env = {
    --   ASPNETCORE_ENVIRONMENT = function()
    --     -- todo: request input from ui
    --     return "Development"
    --   end,
    --   ASPNETCORE_URLS = function()
    --     -- todo: request input from ui
    --     return "http://localhost:5050"
    --   end,
    -- },
    -- cwd = function()
    --   -- todo: request input from ui
    --   return vim.fn.getcwd()
    -- end,
  },
}

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("n", "<F5>", "<Cmd>lua require'dap'.continue()<CR>", opts)
map("n", "<F6>", function()
  require("neotest").run.run({ suite = false, strategy = "dap" })
end, opts)
map("n", "<F9>", "<Cmd>lua require'dap'.toggle_breakpoint()<CR>", opts)
map("n", "<F10>", "<Cmd>lua require'dap'.step_over()<CR>", opts)
map("n", "<F11>", "<Cmd>lua require'dap'.step_into()<CR>", opts)
map("n", "<F8>", "<Cmd>lua require'dap'.step_out()<CR>", opts)
map("n", "<leader>dr", "<Cmd>lua require'dap'.repl.open()<CR>", opts)
map("n", "<leader>dl", "<Cmd>lua require'dap'.run_last()<CR>", opts)
map("n", "<leader>dd", function()
  require("neotest").run.run({ suite = false, strategy = "dap" })
end, { noremap = true, silent = true, desc = "debug nearest test" })
map("n", "<leader>dt", function()
  require("neotest").run.run()
end, { noremap = true, silent = true, desc = "run nearest test" })

require("which-key").add({
  { "<leader>t", group = "Neotest", icon = "🧪" },
})

map("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "toggle test summary panel" })

map("n", "<leader>tp", function()
  require("neotest").output_panel.toggle()
end, { desc = "toggle test output panel" })

map("n", "<leader>tr", function()
  require("neotest").run.run()
end, { desc = "run nearest test" })

map("n", "<leader>tS", function()
  require("neotest").run.stop()
end, { desc = "stop test run" })

map("n", "<leader>tA", function()
  require("neotest").run.run({ suite = true })
end, { desc = "Run all tests" })

map("n", "<leader>tF", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run all tests in file" })

map("n", "]t", function()
  require("neotest").jump.next({ status = "failed" })
end, { desc = "jump to next failed test" })

map("n", "[t", function()
  require("neotest").jump.prev({ status = "failed" })
end, { desc = "jump to prev failed test" })

-- anywhere that runs after nvim-dap loads, e.g. inside the plugin's config = function()
vim.fn.sign_define("DapBreakpoint", {
  text = "●", -- or "" if you have nerd fonts
  texthl = "DiagnosticError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapBreakpointCondition", {
  text = "◯",
  texthl = "DiagnosticError",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapLogPoint", {
  text = "◆",
  texthl = "DiagnosticWarn",
  linehl = "",
  numhl = "",
})

vim.fn.sign_define("DapStopped", {
  text = "▶",
  texthl = "DiagnosticOk",
  linehl = "Visual",
  numhl = "DiagnosticOk",
})

vim.fn.sign_define("DapBreakpointRejected", {
  text = "●",
  texthl = "DiagnosticHint",
  linehl = "",
  numhl = "",
})
