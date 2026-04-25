local function find_mago()
  local local_mago = vim.fn.getcwd() .. "/vendor/bin/mago"

  if vim.fn.executable(local_mago) == 1 then
    return local_mago
  end

  return "mago"
end

local plugin = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "php" })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "intelephense",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {},
        phpactor = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = {
        php = { "mago" },
      },
      formatters = {
        mago = {
          command = find_mago,
          args = {
            "format",
            "--stdin-input",
          },
          stdin = true,
        },
      },
      notify_on_error = true,
    },
  },
}

return plugin
