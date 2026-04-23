local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Auto-resize splits on window resize
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Auto-create parent directories on save
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Go to last cursor position when opening file
autocmd("BufReadPost", {
  group = augroup("last_cursor_position", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Project selection on startup (when opened with no args)
autocmd("VimEnter", {
  group = augroup("project_selection", { clear = true }),
  nested = true,
  callback = function()
    if vim.fn.argc() > 0 then return end
    if vim.fn.line2byte("$") ~= -1 then return end
    if not vim.tbl_isempty(vim.v.argv and vim.tbl_filter(function(a) return a == "-" end, vim.v.argv) or {}) then return end

    vim.schedule(function()
      local ok, Snacks = pcall(require, "snacks")
      if not ok then return end
      Snacks.picker.projects({
        confirm = function(picker, item)
          picker:close()
          if not item then
            Snacks.dashboard.open()
            return
          end
          local dir = item.file or item._path or item.dir
          if dir and vim.fn.isdirectory(dir) == 1 then
            vim.fn.chdir(dir)
          end
          Snacks.dashboard.open()
        end,
      })
    end)
  end,
})

-- Close specific filetypes with q
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = { "help", "qf", "lspinfo", "man", "notify", "checkhealth", "grug-far", "gitsigns-blame" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
