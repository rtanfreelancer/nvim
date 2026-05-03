return {
  -- Rails navigation and tooling
  {
    "weizheheng/ror.nvim",
    ft = { "ruby", "eruby" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "saghen/blink.cmp",
      "nvim-telescope/telescope.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim",  build = "make" },
      { "nvim-telescope/telescope-ui-select.nvim" },
    },
    keys = {
      -- Command palette
      { "<leader>rc", function() require("ror.commands").list_commands() end,          desc = "Rails commands" },
      -- Generate / destroy
      { "<leader>rg", function() require("ror.generators").select_generators() end,    desc = "Generate" },
      { "<leader>rd", function() require("ror.destroyers").select_destroyers() end,    desc = "Destroy" },
      -- Routes
      { "<leader>rr", function() require("ror.routes").list_routes() end,              desc = "List routes" },
      { "<leader>rR", function() require("ror.routes").sync_routes() end,              desc = "Sync routes" },
      -- Schema
      { "<leader>rs", function() require("ror.schema").list_table_columns() end,       desc = "Schema columns" },
      -- DB
      { "<leader>rm", function() require("ror.runners.db_migrate").run() end,          desc = "DB migrate" },
      { "<leader>rM", function() require("ror.runners.db_migrate_status").run() end,   desc = "DB migrate status" },
      { "<leader>rk", function() require("ror.runners.db_rollback").run() end,         desc = "DB rollback" },
      -- Bundle
      { "<leader>rb", function() require("ror.runners.bundle_install").run() end,      desc = "Bundle install" },
      { "<leader>rB", function() require("ror.runners.bundle_update").run() end,       desc = "Bundle update" },
      -- Console (terminal split)
      {
        "<leader>rC",
        function()
          local cmd = vim.fn.filereadable("bin/rails") == 1 and "bin/rails console" or "rails console"
          vim.cmd("botright split | resize 15 | terminal " .. cmd)
          vim.cmd("startinsert")
        end,
        desc = "Rails console",
      },
    },
    config = function()
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("ui-select")
      require("ror").setup({})
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("ruby_lsp", {
        capabilities = capabilities,
        init_options = {
          formatter = "none", -- deferred to conform.nvim
          linters = { "rubocop" },
          addonSettings = {
            ["Ruby LSP Rails"] = {
              enablePendingMigrationsPrompt = true,
            },
          },
        },
      })
      vim.lsp.enable("ruby_lsp")
    end,
  },

  -- Ruby/ERB formatters
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.ruby = { "rubocop" }
      opts.formatters_by_ft.eruby = { "erb_format" }
    end,
  },
}
