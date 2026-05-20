return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
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

      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enable_commands = true,
          clear_on_continue = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = true,
          show_stop_reason = true,
          commented = false,
          only_first_definition = false,
          all_references = true,
          virt_text_pos = "eol",
          all_frames = false,
          virt_lines = false,
          display_callback = function(variable, _buf, _stackframe, _node, options)
            local val = variable.value or ""
            if options.virt_text_pos == "inline" then
              return " = " .. val
            end
            if #val > 80 then val = val:sub(1, 80) .. "…" end
            return "  ▸ " .. variable.name .. " = " .. val
          end,
        },
      },

      {
        "jay-babu/mason-nvim-dap.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
          ensure_installed = { "python", "php", "js-debug-adapter" },
          automatic_installation = true,
          handlers = {
            function(config)
              require("mason-nvim-dap").default_setup(config)
            end,
            ["js-debug-adapter"] = function()
              local dap = require("dap")
              local server = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js"
              for _, name in ipairs({ "pwa-node", "pwa-chrome" }) do
                dap.adapters[name] = {
                  type = "server",
                  host = "localhost",
                  port = "${port}",
                  executable = {
                    command = "node",
                    args = { server, "${port}" },
                  },
                }
              end
            end,
          },
        },
      },

      {
        "suketa/nvim-dap-ruby",
        config = function() require("dap-ruby").setup() end,
      },

      {
        "Weissle/persistent-breakpoints.nvim",
        opts = {
          load_breakpoints_event = { "BufReadPost" },
        },
      },

      {
        "ofirgall/goto-breakpoints.nvim",
      },
    },
    keys = function()
      local keys = {
        { "<leader>db", function() require("persistent-breakpoints.api").toggle_breakpoint() end, desc = "Toggle breakpoint" },
        { "<leader>dB", function() require("persistent-breakpoints.api").set_conditional_breakpoint() end, desc = "Conditional breakpoint" },
        { "<leader>dC", function() require("persistent-breakpoints.api").clear_all_breakpoints() end, desc = "Clear all breakpoints" },
        { "]b", function() require("goto-breakpoints").next() end, desc = "Next breakpoint" },
        { "[b", function() require("goto-breakpoints").prev() end, desc = "Prev breakpoint" },
        { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
        { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
        { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
        { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
        { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
        { "<leader>du", function() require("dap-view").toggle() end, desc = "Toggle DAP UI" },
        { "<leader>de", "<cmd>DapViewWatch<cr>", desc = "Watch expression", mode = { "n", "v" } },
        { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      }
      if vim.g.gaf then
        vim.list_extend(keys, require("gaf.dap").keys())
      end
      return keys
    end,
    config = function()
      vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#2e4030" })
      vim.api.nvim_set_hl(0, "NvimDapVirtualText",        { fg = "#7aa7d6", italic = true })
      vim.api.nvim_set_hl(0, "NvimDapVirtualTextChanged", { fg = "#e0af68", italic = true, bold = true })
      vim.api.nvim_set_hl(0, "NvimDapVirtualTextError",   { fg = "#db4b4b", italic = true })
      vim.api.nvim_set_hl(0, "NvimDapVirtualTextInfo",    { fg = "#9ece6a", italic = true })
      vim.fn.sign_define("DapBreakpoint",          { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "◆", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapBreakpointRejected",  { text = "", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapLogPoint",            { text = "◆", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapStopped",             { text = "▶", texthl = "DiagnosticOk", linehl = "DapStoppedLine" })

      if vim.g.gaf then require("gaf.dap").setup_php_configuration() end

      local dap = require("dap")
      for _, ft in ipairs({ "typescript", "javascript" }) do
        dap.configurations[ft] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Jest: debug current file",
            runtimeExecutable = "node",
            runtimeArgs = { "${workspaceFolder}/node_modules/jest/bin/jest.js", "--runInBand", "${file}" },
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
            internalConsoleOptions = "neverOpen",
            sourceMaps = true,
          },
          {
            type = "pwa-chrome",
            request = "launch",
            name = "Chrome: attach ng serve (localhost:4200)",
            url = "http://localhost:4200",
            webRoot = "${workspaceFolder}",
            sourceMaps = true,
          },
        }
      end
    end,
  },
}
