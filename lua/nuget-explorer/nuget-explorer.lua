-- ~/.config/nvim/lua/nuget_explorer/init.lua
local M = {}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local Job = require("plenary.job")

local PAGE_SIZE = 100

-- find nearest .csproj above current file
local function find_csproj(start_path)
  local path = vim.fn.fnamemodify(start_path, ":p:h")
  while path ~= "/" do
    local csproj = vim.fn.glob(path .. "/*.csproj")
    if csproj ~= "" then
      return csproj
    end
    path = vim.fn.fnamemodify(path, ":h")
  end
  return nil
end

-- change space to %20 for correct URL encoding
local function url_encode(str)
  if not str then
    return ""
  end
  return str:gsub("([^%w%-._~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
end

-- list installed packages from .csproj
local function get_installed_packages()
  local packages = {}
  for csproj in io.popen("ls *.csproj"):lines() do
    for line in io.popen('grep "<PackageReference" ' .. csproj):lines() do
      local name = line:match('Include="(.-)"')
      local version = line:match('Version="(.-)"')
      table.insert(packages, (name or "") .. (version and "@" .. version or ""))
    end
  end
  return packages
end

-- fetch a single NuGet page
local function fetch_nuget_page(query, skip, callback)
  local url =
    string.format("https://api-v2v3search-0.nuget.org/query?q=%s&skip=%d&take=%d", url_encode(query), skip, PAGE_SIZE)
  Job:new({
    command = "curl",
    args = { "-s", url },
    on_exit = function(j)
      vim.schedule(function()
        local ok, data = pcall(vim.fn.json_decode, table.concat(j:result(), "\n"))
        if not ok then
          vim.notify("Failed to parse NuGet JSON", vim.log.levels.ERROR)
          return
        end

        local results = {}
        for _, pkg in ipairs(data.data or {}) do
          table.insert(results, pkg.id .. "@" .. pkg.version)
        end

        callback(results)
      end)
    end,
  }):start()
end

-- picker for online NuGet search with lazy "Load More" pagination
function M.search_online()
  vim.ui.input({ prompt = "Search NuGet package: " }, function(query)
    if not query or query == "" then
      return
    end

    local results = {}
    local skip = 0
    local more = true

    -- fetch next page function
    local function fetch_next_page()
      fetch_nuget_page(query, skip, function(page_results)
        if #page_results < PAGE_SIZE then
          more = false
        end

        for _, pkg in ipairs(page_results) do
          table.insert(results, pkg)
        end
        if more then
          table.insert(results, "Load more...")
        end
        skip = skip + PAGE_SIZE
        open_picker()
      end)
    end

    -- picker opener
    function open_picker()
      pickers
        .new({}, {
          prompt_title = "NuGet Search: " .. query,
          finder = finders.new_table({ results = results }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if not selection then
                return
              end

              if selection.value == "Load more..." then
                fetch_next_page()
                return
              end

              local current_file = vim.api.nvim_buf_get_name(0)
              local csproj_file = find_csproj(current_file)
              if not csproj_file then
                vim.notify("No .csproj found for current file!", vim.log.levels.ERROR)
                return
              end

              local name, version = selection.value:match("(.+)@(.+)")
              if not name then
                vim.notify("Invalid package: " .. selection.value, vim.log.levels.ERROR)
                return
              end

              Job:new({
                command = "dotnet",
                args = { "add", csproj_file, "package", name, "--version", version },
                cwd = vim.fn.fnamemodify(csproj_file, ":h"),
                on_exit = function(j, return_val)
                  vim.schedule(function()
                    if return_val == 0 then
                      vim.notify("Installed " .. name .. "@" .. version, vim.log.levels.INFO)
                      -- reload csproj buffers
                      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                        local buf_name = vim.api.nvim_buf_get_name(buf)
                        if buf_name:match("%.csproj$") then
                          vim.api.nvim_buf_call(buf, function()
                            vim.cmd("edit!")
                          end)
                        end
                      end
                    else
                      vim.notify("Failed to install " .. name .. "@" .. version, vim.log.levels.ERROR)
                    end
                  end)
                end,
              }):start()
            end)
            return true
          end,
        })
        :find()
    end

    -- initial page
    fetch_next_page()
  end)
end

-- picker for installed packages
function M.show_installed()
  local packages = get_installed_packages()
  pickers
    .new({}, {
      prompt_title = "Installed NuGet Packages",
      finder = finders.new_table({ results = packages }),
      sorter = conf.generic_sorter({}),
    })
    :find()
end

-- user commands
vim.api.nvim_create_user_command("NuGetInstalled", M.show_installed, {})
vim.api.nvim_create_user_command("NuGetSearch", M.search_online, {})

return M
