-- Ruby test profiler: stackprof → d3-flamegraph HTML.
-- Requires `gem "stackprof"` in target project's Gemfile.

local M = {}

local function project_root(file)
  local found = vim.fs.find({ "Gemfile", ".git" }, { upward = true, path = vim.fs.dirname(file) })[1]
  return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

local function detect_runner(root, file)
  if file:match("_spec%.rb$") then
    if vim.fn.executable(root .. "/bin/rspec") == 1 then
      return { "bin/rspec" }
    end
    return { "bundle", "exec", "rspec" }
  end
  if vim.fn.filereadable(root .. "/bin/rails") == 1 then
    return { "bin/rails", "test" }
  end
  return { "bundle", "exec", "ruby", "-Itest" }
end

function M.run(file)
  local root = project_root(file)
  local ts = os.date("%Y%m%d-%H%M%S")
  local dump = root .. "/tmp/stackprof-" .. ts .. ".dump"
  local html = root .. "/tmp/stackprof-" .. ts .. ".html"
  vim.fn.mkdir(root .. "/tmp", "p")

  require("config.profile").remember(M.run, file)

  local cmd = { "bundle", "exec", "stackprof", "run", "--raw", "--out", dump, "--" }
  vim.list_extend(cmd, detect_runner(root, file))
  table.insert(cmd, file)

  vim.notify("Profiling: " .. table.concat(cmd, " "), vim.log.levels.INFO)
  vim.system(cmd, { cwd = root, text = true }, vim.schedule_wrap(function(out)
    if out.code ~= 0 then
      vim.notify("stackprof run failed:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      return
    end
    vim.system({ "bundle", "exec", "stackprof", "--d3-flamegraph", dump }, { cwd = root, text = true }, vim.schedule_wrap(function(flame)
      if flame.code ~= 0 then
        vim.notify("Flamegraph generation failed:\n" .. (flame.stderr or ""), vim.log.levels.ERROR)
        return
      end
      local f = io.open(html, "w")
      if not f then
        vim.notify("Cannot write " .. html, vim.log.levels.ERROR)
        return
      end
      f:write(flame.stdout)
      f:close()
      vim.notify("Profile saved: " .. html, vim.log.levels.INFO)
      vim.fn.jobstart({ "open", html }, { detach = true })
    end))
  end))
end

function M.run_current()
  M.run(vim.fn.expand("%:p"))
end

return M
