local M = {}

---@class lazyjira.WindowConfig
---@field width number Fraction (0<n<=1) of the editor, or absolute columns (>1)
---@field height number Fraction (0<n<=1) of the editor, or absolute rows (>1)
---@field border string|string[] Any nvim_open_win border value
---@field relative string nvim_open_win `relative` value
---@field title string Float title (Neovim 0.9+)
---@field title_pos string Title position ("left"|"center"|"right")
---@field zindex integer Float z-index
---@field winblend integer Window transparency (0-100)

---@class lazyjira.Keymaps
---@field close string|false Buffer-local "hide window" mapping, or false to disable

---@class lazyjira.Config
---@field cmd string|string[] Command used to launch lazyjira
---@field args string[] Extra args appended to `cmd`
---@field window lazyjira.WindowConfig
---@field start_insert boolean Enter terminal-mode on open
---@field keymaps lazyjira.Keymaps
---@field on_open? fun(term: lazyjira.Terminal)
---@field on_exit? fun(code: integer)

---@type lazyjira.Config
M.defaults = {
  cmd = "lazyjira",
  args = {},
  window = {
    width = 0.9,
    height = 0.9,
    border = "rounded",
    relative = "editor",
    title = " lazyjira ",
    title_pos = "center",
    zindex = 50,
    winblend = 0,
  },
  start_insert = true,
  keymaps = {
    close = false,
  },
}

---The active configuration (defaults until `merge()` is called).
---@type lazyjira.Config
M.options = vim.deepcopy(M.defaults)

local KNOWN = {
  cmd = true,
  args = true,
  window = true,
  start_insert = true,
  keymaps = true,
  on_open = true,
  on_exit = true,
}

---@param opts table
local function warn_unknown(opts)
  for key in pairs(opts) do
    if not KNOWN[key] then
      vim.notify(("lazyjira: unknown config key '%s'"):format(key), vim.log.levels.WARN)
    end
  end
end

---@param cfg lazyjira.Config
local function validate(cfg)
  local cmd_type = type(cfg.cmd)
  assert(cmd_type == "string" or cmd_type == "table", "lazyjira: `cmd` must be a string or string[]")
  assert(type(cfg.args) == "table", "lazyjira: `args` must be a table")
  assert(type(cfg.window) == "table", "lazyjira: `window` must be a table")
  assert(type(cfg.window.width) == "number", "lazyjira: `window.width` must be a number")
  assert(type(cfg.window.height) == "number", "lazyjira: `window.height` must be a number")
  assert(type(cfg.start_insert) == "boolean", "lazyjira: `start_insert` must be a boolean")
  assert(
    cfg.on_open == nil or type(cfg.on_open) == "function",
    "lazyjira: `on_open` must be a function"
  )
  assert(
    cfg.on_exit == nil or type(cfg.on_exit) == "function",
    "lazyjira: `on_exit` must be a function"
  )
end

---Merge user options over the defaults, validate, and store as the active options.
---@param opts? lazyjira.Config
---@return lazyjira.Config
function M.merge(opts)
  opts = opts or {}
  assert(type(opts) == "table", "lazyjira: config must be a table")
  warn_unknown(opts)
  local merged = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts) --[[@as lazyjira.Config]]
  -- `args` is a list; replace it wholesale rather than index-merging with defaults.
  if opts.args ~= nil then
    merged.args = vim.deepcopy(opts.args)
  end
  validate(merged)
  M.options = merged
  return merged
end

return M
