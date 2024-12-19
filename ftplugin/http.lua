vim.api.nvim_buf_set_keymap(
  0,
  "n",
  "<C-k>",
  "<cmd>lua require('kulala').run()<cr>",
  { noremap = true, silent = true, desc = "Execute the request" }
)
