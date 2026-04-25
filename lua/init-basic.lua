if vim.loader then
  vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.autoformat = false
vim.g.markdown_recommended_style = 0

local opt = vim.opt
local keymap = vim.keymap

vim.scriptencoding = "utf-8"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

opt.autowrite = true
opt.number = true
opt.relativenumber = true
opt.title = true
opt.autoindent = true
opt.smartindent = true
opt.hlsearch = true
opt.backup = false
opt.showcmd = true
opt.cmdheight = 1
opt.laststatus = 1
opt.backupskip = { "/tmp/*", "/private/tmp/*" }
opt.expandtab = true
opt.inccommand = "split"
opt.ignorecase = true
opt.smartcase = true
opt.smarttab = true
opt.breakindent = true
opt.shiftwidth = 4
opt.tabstop = 2
opt.wrap = false
opt.linebreak = true
opt.backspace = { "start", "eol", "indent" }
opt.path:append({ "**" })
opt.wildignore:append({ "*/node_modules/*", "*/vendor/*" })
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "cursor"
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
opt.cursorline = true
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.jumpoptions = "view"
opt.mouse = "a"
opt.ruler = false
opt.scrolloff = 4
opt.sidescrolloff = 8
opt.shiftround = true
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false
opt.signcolumn = "yes"
opt.termguicolors = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200
opt.virtualedit = "block"
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.conceallevel = 2

-- Add asterisks in block comments
opt.formatoptions = "jcroqlnt"
opt.formatoptions:append({ "r" })

if vim.fn.has("nvim-0.8") == 1 then
  opt.cmdheight = 0
end

local function is_remote()
  return vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT or vim.env.SSH_TTY
end

if is_remote() then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
else
  vim.g.clipboard = nil
  opt.clipboard = "unnamedplus"
end

local opts = { noremap = true, silent = true }

-- LazyVim built-in keymaps that do not depend on plugins
keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true, desc = "Down" })
keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true, desc = "Up" })
keymap.set("n", "<C-h>", "<C-w>h", { remap = true, desc = "Go to Left Window" })
keymap.set("n", "<C-j>", "<C-w>j", { remap = true, desc = "Go to Lower Window" })
keymap.set("n", "<C-k>", "<C-w>k", { remap = true, desc = "Go to Upper Window" })
keymap.set("n", "<C-l>", "<C-w>l", { remap = true, desc = "Go to Right Window" })
keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })
keymap.set("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
keymap.set("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
keymap.set("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
keymap.set("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
keymap.set("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
keymap.set("n", "]b", "<cmd>bnext<cr>", { desc = "Next Buffer" })
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })

-- Repo custom built-in keymaps
keymap.set("i", "<C-e>", "<esc><S-a>", { silent = true, desc = "End of line" })
keymap.set("n", "<C-e>", "<S-a><esc>", { silent = true, desc = "End of line" })
keymap.set("i", "<C-w>", "<esc><S-i>", { silent = true, desc = "Start of line" })
keymap.set("n", "<C-w>", "<S-i><esc>", { silent = true, desc = "Start of line" })
keymap.set("n", "<S-tab>", ":bprev<Return>", opts)
keymap.set("n", "<F2>", function() vim.diagnostic.goto_next() end)
keymap.set("n", "<C-a>", "gg<S-v>G")
keymap.set("n", "<F3>", "'Nn'[v:searchforward].'zv'", {
  expr = true,
  noremap = true,
  silent = true,
  desc = "Search forward",
})
keymap.set({ "n", "x" }, "<C-C>", '\"+y', { silent = true, desc = "Copy to system clipboard" })
keymap.set("i", "<C-C>", '<Esc>\"+yyA', { silent = true, desc = "Copy line to system clipboard" })

local function augroup(name)
  return vim.api.nvim_create_augroup("standalone_" .. name, { clear = true })
end

-- LazyVim built-in autocmds that do not depend on plugins
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    (vim.hl or vim.highlight).on_yank()
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Repo custom autocmds
vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup("nopaste"),
  pattern = "*",
  command = "set nopaste",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("no_conceal"),
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("filetypes_php"),
  pattern = "*.php",
  command = "setf php",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("filetypes_typescript"),
  pattern = "*.ts",
  command = "setf typescript",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("filetypes_typescriptreact"),
  pattern = "*.tsx",
  command = "setf typescriptreact",
})

vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  group = augroup("filetypes_python"),
  pattern = "*.py",
  command = "setf python",
})

vim.o.termguicolors = true

local ok = pcall(vim.cmd.colorscheme, "habamax")
if not ok then
  vim.cmd.colorscheme("default")
end
