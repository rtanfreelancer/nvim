-- TypeScript/JavaScript test profiler: node --cpu-prof + jest --runInBand.
-- Opens .cpuprofile via speedscope (npx). Drag into Chrome DevTools as fallback.

local M = {}

local function project_root(file)
  local found = vim.fs.find({ "package.json", ".git" }, { upward = true, path = vim.fs.dirname(file) })[1]
  return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

function M.run(file)
  local root = project_root(file)
  local out_dir = root .. "/tmp/cpu-prof"
  vim.fn.mkdir(out_dir, "p")

  require("config.profile").remember(M.run, file)

  local jest = root .. "/node_modules/.bin/jest"
  if vim.fn.executable(jest) ~= 1 then
    vim.notify("jest binary not found at " .. jest, vim.log.levels.ERROR)
    return
  end

  local cmd = {
    "node", "--cpu-prof", "--cpu-prof-dir=" .. out_dir,
    jest, "--runInBand", file,
  }

  vim.notify("Profiling: " .. table.concat(cmd, " "), vim.log.levels.INFO)
  vim.system(cmd, { cwd = root, text = true }, vim.schedule_wrap(function(out)
    if out.code ~= 0 then
      vim.notify("CPU profile failed:\n" .. (out.stderr or ""), vim.log.levels.ERROR)
      return
    end
    local files = vim.fn.glob(out_dir .. "/CPU.*.cpuprofile", false, true)
    table.sort(files)
    local newest = files[#files]
    if not newest then
      vim.notify("No .cpuprofile produced in " .. out_dir, vim.log.levels.WARN)
      return
    end
    vim.notify("Profile saved: " .. newest, vim.log.levels.INFO)
    vim.fn.jobstart({ "npx", "--yes", "speedscope", newest }, { detach = true })
  end))
end

function M.run_current()
  M.run(vim.fn.expand("%:p"))
end

return M
