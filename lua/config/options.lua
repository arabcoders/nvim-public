-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- disable autoformat
vim.g.autoformat = false

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"

vim.opt.number = true

vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 1
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }

vim.opt.expandtab = true
-- vim.opt.scrolloff = 10
vim.opt.inccommand = "split"
vim.opt.ignorecase = true
vim.opt.smarttab = true
vim.opt.breakindent = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 2
vim.opt.wrap = false
vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" })
vim.opt.wildignore:append({ "*/node_modules/*", "*/vendor/*" })
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.splitkeep = "cursor"

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })

vim.cmd([[au BufNewFile,BufRead *.astro setf astro]])
vim.cmd([[au BufNewFile,BufRead Podfile setf ruby]])

if vim.fn.has("nvim-0.8") == 1 then
  vim.opt.cmdheight = 0
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
  -- Local: use native clipboard (xclip/wl-copy)
  vim.g.clipboard = nil
  vim.opt.clipboard = "unnamedplus"
end
