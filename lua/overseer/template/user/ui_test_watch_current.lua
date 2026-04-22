return {
  name = "ui test watch (current)",
  params = {
    spec = {
      type = "string",
      name = "SPEC",
      desc = "Spec pattern (blank = current file)",
      default = "",
      optional = true,
    },
  },
  builder = function(params)
    if params.spec == nil or params.spec == "" then
      params.spec = vim.fn.expand("%:p:r")
    end
    return {
      cmd = { "yarn", "ui:main:watch" },
      env = { SPEC = params.spec },
      components = { "default" },
    }
  end,
  condition = {
    callback = function()
      return vim.fn.filereadable("package.json") == 1
    end,
  },
}
