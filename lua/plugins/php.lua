-- Plugins for PHP language.
local plugin = {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "php" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      -- phpactor
      vim.list_extend(opts.ensure_installed, { "intelephense", "php-cs-fixer" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        intelephense = {},
        --   phpactor = {},
      },
      setup = {},
    },
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      formatters_by_ft = {
        php = { "php-cs-fixer" },
      },
      formatters = {
        ["php-cs-fixer"] = {
          command = "php-cs-fixer",
          args = {
            "fix",
            -- Formatting preset. Other presets are available, see the php-cs-fixer docs.
            "--rules=@PSR12",
            "$FILENAME",
          },
          stdin = false,
        },
      },
      notify_on_error = true,
    },
  },
}

return plugin
