vim.lsp.log.set_level(vim.log.levels.ERROR)

require("config.options")
require("config.lazy")
require("config.keymaps")
require("config.autocmds")
require("config.gaf-xdebug").setup()
