return {
  name = "fli provision (devbox)",
  builder = function()
    return {
      cmd = { "fli", "provision" },
      components = { "default" },
    }
  end,
}
