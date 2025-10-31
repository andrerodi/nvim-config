local km = vim.keymap

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
