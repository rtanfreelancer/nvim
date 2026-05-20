-- Code screenshot via silicon (Rust CLI: `brew install silicon`)
return {
  {
    "michaelrommel/nvim-silicon",
    cmd = { "Silicon", "SiliconAsync" },
    keys = {
      {
        "<leader>cy",
        function() require("nvim-silicon").clip() end,
        mode = { "n", "v" },
        desc = "Code → image (clipboard)",
      },
      {
        "<leader>cY",
        function() require("nvim-silicon").file() end,
        mode = { "n", "v" },
        desc = "Code → image (save file)",
      },
    },
    opts = {
      theme = "gruvbox-dark",
      font = "Hack Nerd Font=18",
      background = "#1d2021",
      pad_horiz = 60,
      pad_vert = 60,
      shadow_blur_radius = 16,
      shadow_offset_x = 8,
      shadow_offset_y = 8,
      shadow_color = "#100808",
      line_pad = 2,
      line_offset = function(args)
        return args.line1
      end,
      tab_width = 2,
      gobble = true,
      output = function()
        return "~/Desktop/silicon-" .. os.date("!%Y-%m-%dT%H-%M-%S") .. ".png"
      end,
      to_clipboard = false,
    },
  },
}
