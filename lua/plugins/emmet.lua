return {
  -- Emmet expansion for HTML/CSS/ERB/JSX/Vue/Svelte.
  -- Leader `<C-y>` + trigger char (`,` to expand, `/` to comment, `n` to next edit point).
  -- ERB inherits HTML snippet set; `<%= %>` / `<% %>` written by hand or via vim-rails.
  {
    "mattn/emmet-vim",
    ft = {
      "html",
      "eruby",
      "css",
      "scss",
      "sass",
      "less",
      "javascriptreact",
      "typescriptreact",
      "vue",
      "svelte",
      "htmldjango",
    },
    init = function()
      vim.g.user_emmet_leader_key = "<C-y>"
      vim.g.user_emmet_settings = {
        indentation = "  ",
        eruby = { extends = "html" },
        javascriptreact = { extends = "jsx" },
        typescriptreact = { extends = "jsx" },
        vue = { extends = "html" },
        svelte = { extends = "html" },
      }
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "html", "eruby", "css", "scss", "sass", "less",
          "javascriptreact", "typescriptreact", "vue", "svelte", "htmldjango",
        },
        callback = function(args)
          vim.keymap.set("n", "<leader>ce", "<plug>(emmet-expand-abbr)",
            { buffer = args.buf, desc = "Emmet: expand abbreviation" })
        end,
      })
    end,
  },
}
