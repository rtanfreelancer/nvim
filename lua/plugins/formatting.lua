local in_freelancer = vim.fn.getcwd():find(vim.fn.expand("~/freelancer-dev"), 1, true) ~= nil

return {
  -- Formatting (manual only — invoke via <leader>cf, see config/keymaps.lua)
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true }) end, mode = { "n", "v" }, desc = "Format file" },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        javascriptreact = { "prettierd", "prettier", stop_after_first = true },
        typescriptreact = { "prettierd", "prettier", stop_after_first = true },
        php = { "php_cs_fixer" },
        python = { "ruff_organize_imports", "ruff_format" },
      },
      formatters = in_freelancer and {
        php_cs_fixer = {
          command = vim.fn.expand("~/freelancer-dev/fl-gaf/support/php-cs-fixer/vendor/bin/php-cs-fixer"),
          args = {
            "fix",
            "--config=" .. vim.fn.expand("~/freelancer-dev/fl-gaf/.php-cs-fixer.dist.php"),
            "--no-interaction",
            "--quiet",
            "$FILENAME",
          },
          stdin = false,
        },
      } or {},
      -- format_on_save removed: php_cs_fixer 5-40s stalls editor on save.
      -- Use <leader>cf (async) or :Format to format current buffer manually.
    },
  },

  -- Linting
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      if in_freelancer then
        local phpcs = lint.linters.phpcs
        phpcs.cmd = "./vendor/bin/phpcs"
        phpcs.args = {
          "-q",
          "--report=json",
          "--standard=" .. vim.fn.expand("~/freelancer-dev/fl-gaf/phpcs_gaf.xml"),
          "-",
        }
      end

      -- phpstan removed from on-save lint: --memory-limit=512M full-project analysis
      -- on every BufWritePost stalled the editor. CI runs phpstan; trigger locally
      -- via :Lint phpstan or `./vendor/bin/phpstan analyse` when needed.
      lint.linters_by_ft = in_freelancer and {
        php = { "phpcs" },
      } or {}

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        group = vim.api.nvim_create_augroup("lint", { clear = true }),
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
}
