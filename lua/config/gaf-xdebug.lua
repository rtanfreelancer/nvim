-- GAF xdebug helpers.
--
-- Wraps `bin/gaf-xdebug` (port-forward + IDE validation tool from fl-gaf).
-- Auto-detects project root by walking up from cwd / current buffer looking
-- for `bin/gaf-xdebug`. DEV_DNS defaults to "gread"; override with
-- `vim.g.gaf_dev_dns` or `$DEV_DNS`.

local M = {}

local function find_root()
  local start = vim.fn.expand("%:p:h")
  if start == "" then start = vim.fn.getcwd() end
  local dir = start
  while dir ~= "/" and dir ~= "" do
    if vim.fn.executable(dir .. "/bin/gaf-xdebug") == 1 then
      return dir
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

local function dev_dns()
  return "rtanjaya"
end

local function run(subcmd, extra_args)
  local root = find_root()
  if not root then
    vim.notify("gaf-xdebug: bin/gaf-xdebug not found (walked up from buffer)", vim.log.levels.ERROR)
    return
  end
  local args = { root .. "/bin/gaf-xdebug", subcmd }
  for _, a in ipairs(extra_args or {}) do table.insert(args, a) end

  local lines = {}
  vim.notify("gaf-xdebug " .. subcmd .. " (DEV_DNS=" .. dev_dns() .. ")", vim.log.levels.INFO)
  vim.fn.jobstart(args, {
    cwd = root,
    env = vim.tbl_extend("force", vim.fn.environ(), { DEV_DNS = dev_dns() }),
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data) if data then vim.list_extend(lines, data) end end,
    on_stderr = function(_, data) if data then vim.list_extend(lines, data) end end,
    on_exit = function(_, code)
      local level = code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
      local output = table.concat(vim.tbl_filter(function(l) return l ~= "" end, lines), "\n")
      vim.notify("gaf-xdebug " .. subcmd .. " exit=" .. code ..
        (output ~= "" and ("\n" .. output) or ""), level)
    end,
  })
end

function M.start() run("start") end
function M.stop() run("stop") end
function M.validate() run("validate") end
function M.logs() run("logs") end

function M.insert_connect()
  local line = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(0, line, line, false, { "xdebug_connect_to_client();" })
end

function M.setup()
  vim.api.nvim_create_user_command("GafXdebugStart",    function() M.start() end,    { desc = "GAF xdebug: start port-forward" })
  vim.api.nvim_create_user_command("GafXdebugStop",     function() M.stop() end,     { desc = "GAF xdebug: stop port-forward" })
  vim.api.nvim_create_user_command("GafXdebugValidate", function() M.validate() end, { desc = "GAF xdebug: validate IDE setup" })
  vim.api.nvim_create_user_command("GafXdebugLogs",     function() M.logs() end,     { desc = "GAF xdebug: tail logs" })
  vim.api.nvim_create_user_command("GafXdebugInsert",   function() M.insert_connect() end,
    { desc = "Insert xdebug_connect_to_client();" })
end

return M
