local paths = require("gaf.paths")
local infra = require("gaf.test_infra")

local M = {}

function M.keys()
  return {
    { "<leader>dx", "<cmd>GafXdebugStart<cr>",    desc = "GAF xdebug: start port-forward" },
    { "<leader>dX", "<cmd>GafXdebugStop<cr>",     desc = "GAF xdebug: stop port-forward" },
    { "<leader>dv", "<cmd>GafXdebugValidate<cr>", desc = "GAF xdebug: validate" },
    { "<leader>dD", infra.toggle_debug_flag,      desc = "Toggle GAF test --debug flag" },
  }
end

function M.setup_php_configuration()
  -- Set directly (not via FileType autocmd) so the config is present even when
  -- DAP loads after a PHP buffer was already opened. Previously used `once=true`
  -- FileType "php" autocmd, which never fired if FileType already triggered
  -- before dap plugin loaded — causing neotest-phpunit's dap strategy to crash
  -- with "dap: expected not empty table, got nil".
  require("dap").configurations.php = {
    {
      type = "php",
      request = "launch",
      name = "Listen for Xdebug (:9003)",
      port = 9003,
      log = false,
      stopOnEntry = false,
      pathMappings = {
        [paths.remote_root] = paths.fl_gaf,
      },
    },
  }
end

return M
