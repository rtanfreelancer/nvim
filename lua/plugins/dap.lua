return {
  -- Debug Adapter Protocol
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- DAP UI (modern tabbed panel)
      {
        "igorlfs/nvim-dap-view",
        opts = {
          winbar = {
            sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "console" },
            default_section = "scopes",
          },
          windows = {
            size = 12,
          },
        },
        config = function(_, opts)
          local dap, dv = require("dap"), require("dap-view")
          dv.setup(opts)

          dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
          dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
          dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
          dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end
        end,
      },

      -- Virtual text for variable values
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },

      -- Auto-install debug adapters via Mason
      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
          ensure_installed = { "python", "php" },
          automatic_installation = true,
          handlers = {
            function(config)
              require("mason-nvim-dap").default_setup(config)
            end,
          },
        },
      },
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dap-view").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>de", "<cmd>DapViewWatch<cr>", desc = "Watch expression", mode = { "n", "v" } },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dx", "<cmd>GafXdebugStart<cr>",    desc = "GAF xdebug: start port-forward" },
      { "<leader>dX", "<cmd>GafXdebugStop<cr>",     desc = "GAF xdebug: stop port-forward" },
      { "<leader>dv", "<cmd>GafXdebugValidate<cr>", desc = "GAF xdebug: validate" },
      { "<leader>dD", function()
          vim.g.gaf_test_debug = not vim.g.gaf_test_debug
          if vim.g.gaf_test_debug then
            vim.env.GAF_DEBUG = "1"
            vim.notify("GAF_DEBUG=1 (next neotest run will pass --debug)", vim.log.levels.INFO)
          else
            vim.env.GAF_DEBUG = nil
            vim.notify("GAF_DEBUG cleared", vim.log.levels.INFO)
          end
        end, desc = "Toggle GAF test --debug flag" },
    },
    config = function()
      -- Breakpoint signs with explicit highlight groups
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e4030" })
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })

      -- PHP / xdebug configurations (Freelancer GAF). Single listener config —
      -- pathMappings are harmless for local runs (paths already match) and
      -- required for remote (devbox /mnt/gaf → local checkout).
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        once = true,
        callback = function()
          local dap = require("dap")
          local fl_gaf = vim.fn.expand("~/freelancer-dev/fl-gaf")
          dap.configurations.php = {
            {
              type = "php",
              request = "launch",
              name = "Listen for Xdebug (:9003)",
              port = 9003,
              log = false,
              stopOnEntry = false,
              pathMappings = {
                ["/mnt/gaf"] = fl_gaf,
              },
            },
          }
        end,
      })
    end,
  },
}
