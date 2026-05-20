-- Obsidian workflow helpers: prompt for title, slugify, create note from template
-- under a specific subfolder of the vault.
local M = {}

---@param s string
---@return string
local function slugify(s)
  s = s:lower()
  s = s:gsub("[^%w%s%-_]", "")
  s = s:gsub("%s+", "-")
  s = s:gsub("%-+", "-")
  s = s:gsub("^%-", ""):gsub("%-$", "")
  return s
end

---@param opts { folder: string, template: string, prompt?: string, date_prefix?: boolean }
function M.new_from_template(opts)
  vim.ui.input({ prompt = opts.prompt or "Title: " }, function(input)
    if not input or input == "" then
      return
    end
    local slug = slugify(input)
    if opts.date_prefix then
      slug = os.date("%Y-%m-%d") .. "-" .. slug
    end
    local id = opts.folder .. "/" .. slug
    -- :Obsidian new_from_template <id...> <template>
    vim.cmd(string.format("Obsidian new_from_template %s %s", id, opts.template))
  end)
end

---@param folder string
function M.capture(folder)
  vim.ui.input({ prompt = "Capture title: " }, function(input)
    if not input or input == "" then
      return
    end
    local slug = os.date("%Y-%m-%d-%H%M") .. "-" .. slugify(input)
    vim.cmd(string.format("Obsidian new_from_template %s/%s inbox", folder, slug))
  end)
end

function M.weekly_review()
  local year = os.date("%Y")
  local week = os.date("%V")
  local id = string.format("notes/reviews/%s-W%s", year, week)
  vim.cmd(string.format("Obsidian new_from_template %s weekly", id))
end

return M
