if vim.loader then
  vim.loader.enable()
end

vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.autoformat = false
vim.g.markdown_recommended_style = 0

local opt = vim.opt
local keymap = vim.keymap

opt.fileencoding = "utf-8"

opt.autowrite = true
opt.number = true
opt.relativenumber = true
opt.title = true
opt.smartindent = true
opt.laststatus = 1
opt.backupskip = { "/tmp/*", "/private/tmp/*" }
opt.expandtab = true
opt.inccommand = "split"
opt.ignorecase = true
opt.smartcase = true
opt.breakindent = true
opt.shiftwidth = 4
opt.tabstop = 2
opt.wrap = false
opt.linebreak = true
opt.path:append({ "**" })
opt.wildignore:append({ "*/node_modules/*", "*/vendor/*" })
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "cursor"
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true
opt.cursorline = true
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

if vim.fn.has("nvim-0.8") == 1 then
  opt.cmdheight = 0
end

local parent_env = nil

local function read_file(path)
  local file = io.open(path, "rb")
  if not file then
    return nil
  end

  local data = file:read("*a")
  file:close()
  return data
end

local function load_parent_env()
  if parent_env ~= nil then
    return parent_env
  end

  parent_env = {}
  local pid = tostring(vim.fn.getpid())

  for _ = 1, 12 do
    local status = read_file("/proc/" .. pid .. "/status")
    if not status then
      break
    end

    local ppid = status:match("\nPPid:%s+(%d+)") or status:match("^PPid:%s+(%d+)")
    if not ppid or ppid == "0" then
      break
    end

    local environ = read_file("/proc/" .. ppid .. "/environ")
    if environ then
      for entry in environ:gmatch("([^%z]+)") do
        local key, value = entry:match("^([^=]+)=(.*)$")
        if key and value and parent_env[key] == nil then
          parent_env[key] = value
        end
      end
    end

    pid = ppid
  end

  return parent_env
end

local function inherited_env(name)
  local value = vim.env[name]
  if value and value ~= "" then
    return value
  end

  return load_parent_env()[name]
end

local function is_remote()
  return inherited_env("SSH_CONNECTION") or inherited_env("SSH_CLIENT") or inherited_env("SSH_TTY")
end

if is_remote() then
  -- Remote: use OSC52 (copies through terminal)
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
  -- Let Neovim choose the best builtin provider (tmux/xclip/wl-copy/etc.)
  vim.g.clipboard = nil
  opt.clipboard = "unnamedplus"
end

vim.filetype.add({
  extension = {
    req = "http",
  },
  filename = {
    Caddyfile = "caddyfile",
    Podfile = "ruby",
  },
  pattern = {
    [".*%.Caddyfile"] = "caddyfile",
  },
})

local opts = { noremap = true, silent = true }

local function toggle_list(kind)
  local ok_toggle, err = pcall(function()
    if kind == "loc" then
      if vim.fn.getloclist(0, { winid = 0 }).winid ~= 0 then
        vim.cmd.lclose()
      else
        vim.cmd.lopen()
      end
      return
    end

    if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
      vim.cmd.cclose()
    else
      vim.cmd.copen()
    end
  end)

  if not ok_toggle and err then
    vim.notify(err, vim.log.levels.ERROR)
  end
end

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
keymap.set("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap.set("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
keymap.set({ "i", "n" }, "<esc>", function()
  vim.cmd("nohlsearch")
  return "<esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })
keymap.set("n", "<leader>ur", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", {
  desc = "Redraw / Clear hlsearch / Diff Update",
})
keymap.set("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
keymap.set("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
keymap.set("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
keymap.set("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
keymap.set("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
keymap.set("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
keymap.set({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save File" })
keymap.set("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })
keymap.set("x", "<", "<gv")
keymap.set("x", ">", ">gv")
local diagnostic_goto = function(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end
keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
keymap.set("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
keymap.set("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
keymap.set("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
keymap.set("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
keymap.set("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
keymap.set("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
keymap.set("n", "<leader>xl", function()
  toggle_list("loc")
end, { desc = "Location List" })
keymap.set("n", "<leader>xq", function()
  toggle_list("qf")
end, { desc = "Quickfix List" })
keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })
keymap.set("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit All" })
keymap.set("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })
keymap.set("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })
keymap.set("n", "<leader>-", "<C-W>s", { remap = true, desc = "Split Window Below" })
keymap.set("n", "<leader>|", "<C-W>v", { remap = true, desc = "Split Window Right" })
keymap.set("n", "<leader>wd", "<C-W>c", { remap = true, desc = "Delete Window" })
keymap.set("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
keymap.set("n", "<leader><tab>o", "<cmd>tabonly<cr>", { desc = "Close Other Tabs" })
keymap.set("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
keymap.set("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
keymap.set("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
keymap.set("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
keymap.set("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- Repo custom built-in keymaps
keymap.set("i", "<C-e>", "<esc><S-a>", { silent = true, desc = "End of line" })
keymap.set("i", "<C-w>", "<esc><S-i>", { silent = true, desc = "Start of line" })
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

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].filetype == "gitcommit" or vim.b[buf].standalone_last_loc then
      return
    end

    vim.b[buf].standalone_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local line_count = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = { "checkhealth", "help", "man", "qf" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      keymap.set("n", "q", function()
        vim.cmd("close")
        pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
      end, {
        buffer = event.buf,
        silent = true,
        desc = "Quit buffer",
      })
    end)
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
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
  pattern = { "json", "json5", "jsonc", "markdown" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end

    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

local ok = pcall(vim.cmd.colorscheme, "habamax")
if not ok then
  vim.cmd.colorscheme("default")
end
