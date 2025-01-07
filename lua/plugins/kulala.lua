vim.filetype.add({
  extension = {
    ["http"] = "http",
    ["req"] = "http",
  },
})

return {
  {
    "mistweaverco/kulala.nvim",
    dependencies = { { "nvim-lua/plenary.nvim" } },
    opts = {
      default_view = "headers_body",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "http" })
    end,
  },
}
