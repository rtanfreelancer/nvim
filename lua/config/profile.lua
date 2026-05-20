local M = {}

M._last = nil

function M.remember(runner, file)
  M._last = { runner = runner, file = file }
end

function M.run_last()
  local l = M._last
  if not l then
    vim.notify("No previous profile run", vim.log.levels.WARN)
    return
  end
  l.runner(l.file)
end

return M
