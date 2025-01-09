local plugin = {
  {
    "catppuccin/nvim",
    priority = 1000,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}

return plugin
