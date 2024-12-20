local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set({ "n", "i", "v" }, "<C-A-l>", function()
  LazyVim.format({ force = true })
end, {
  noremap = true,
  silent = true,
  desc = "Format Document",
})

keymap.set("i", "<C-e>", "<esc><S-a>", { silent = true, desc = "End of line" })
keymap.set("n", "<C-e>", "<S-a><esc>", { silent = true, desc = "End of line" })
keymap.set("i", "<C-w>", "<esc><S-i>", { silent = true, desc = "Start of line" })
keymap.set("n", "<C-w>", "<S-i><esc>", { silent = true, desc = "Start of line" })

keymap.del("n", "<C-W><C-D>")
keymap.del("n", "<C-W><leader>")
keymap.del("n", "<C-W>d")

-- Switch buffers
keymap.set("n", "<S-tab>", ":bprev<Return>", opts)

keymap.set("n", "<F2>", function()
  vim.diagnostic.goto_next()
end)

keymap.set("n", "<C-a>", "gg<S-v>G")

-- F18 is shift+F6
keymap.set("n", "<F18>", "<LEADER>cr", { silent = false, desc = "Trigger code refactor." })

-- F3 search forward
keymap.set("n", "<F3>", "'Nn'[v:searchforward].'zv'", {
  expr = true,
  noremap = true,
  silent = true,
  desc = "Search forward",
})

keymap.set({ "n", "x", "i" }, "<C-C>", '"*y', { silent = true, desc = "Copy to system clipboard" })
