return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "caddy" })
    end,
  },
  {
    "isobit/vim-caddyfile",
    ft = "caddyfile",
    config = function()
      vim.filetype.add({
        filename = {
          ["Caddyfile"] = "caddyfile",
        },
        pattern = {
          ["*.Caddyfile"] = "caddyfile",
        },
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = {
        caddyfile = { "caddyfmt" },
      },
      formatters = {
        ["caddyfmt"] = {
          command = "caddy",
          args = {
            "fmt",
            "-",
          },
          stdin = true,
        },
      },
      notify_on_error = true,
    },
  },
}
