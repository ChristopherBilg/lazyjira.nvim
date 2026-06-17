local config = require("lazyjira.config")

local M = {}

---@class lazyjira.Terminal
---@field buf integer|nil
---@field win integer|nil
---@field job integer|nil
local state = { buf = nil, win = nil, job = nil }

local augroup = vim.api.nvim_create_augroup("lazyjira", { clear = true })

---@param value number
---@param total integer
---@return integer
local function resolve_dim(value, total)
  if value <= 1 then
    return math.floor(total * value)
  end
  return math.floor(value)
end

---@return vim.api.keyset.win_config
local function win_config()
  local w = config.options.window
  local width = resolve_dim(w.width, vim.o.columns)
  local height = resolve_dim(w.height, vim.o.lines)
  ---@type vim.api.keyset.win_config
  local cfg = {
    relative = w.relative,
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = w.border,
    zindex = w.zindex,
    style = "minimal",
  }
  if vim.fn.has("nvim-0.9") == 1 and w.title and w.title ~= "" then
    cfg.title = w.title
    cfg.title_pos = w.title_pos
  end
  return cfg
end

---@return boolean
function M.is_open()
  return state.win ~= nil and vim.api.nvim_win_is_valid(state.win)
end

---@return boolean
local function has_buf()
  return state.buf ~= nil and vim.api.nvim_buf_is_valid(state.buf)
end

---@return string
local function cmd_name()
  local cmd = config.options.cmd
  if type(cmd) == "table" then
    return cmd[1]
  end
  return cmd
end

---@return string[]
local function resolved_cmd()
  local cmd = config.options.cmd
  local list = type(cmd) == "table" and vim.deepcopy(cmd) or { cmd }
  ---@cast list string[]
  for _, arg in ipairs(config.options.args) do
    table.insert(list, arg)
  end
  return list
end

local function teardown()
  local win, buf = state.win, state.buf
  -- Clear state first so the WinClosed autocmd short-circuits during the close below.
  state.buf, state.win, state.job = nil, nil, nil
  if win ~= nil and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  if buf ~= nil and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
end

local function apply_window_opts()
  vim.wo[state.win].winblend = config.options.window.winblend
end

local function set_keymaps()
  local close = config.options.keymaps and config.options.keymaps.close
  if type(close) == "string" then
    vim.keymap.set("t", close, function()
      M.hide()
    end, { buffer = state.buf, desc = "lazyjira: hide window" })
  end
end

---Open the lazyjira window, revealing an existing session if one is hidden.
function M.open()
  if M.is_open() then
    return
  end

  -- Reveal an existing (hidden) session.
  if has_buf() and state.job then
    state.win = vim.api.nvim_open_win(state.buf, true, win_config())
    apply_window_opts()
    if config.options.start_insert then
      vim.cmd.startinsert()
    end
    if config.options.on_open then
      config.options.on_open(state)
    end
    return
  end

  -- Fresh session: verify the binary exists first.
  local name = cmd_name()
  if vim.fn.executable(name) == 0 then
    vim.notify(
      ("lazyjira: '%s' not found in PATH. Install it: https://github.com/textfuel/lazyjira"):format(
        name
      ),
      vim.log.levels.ERROR
    )
    return
  end

  state.buf = vim.api.nvim_create_buf(false, true)
  vim.bo[state.buf].filetype = "lazyjira"
  state.win = vim.api.nvim_open_win(state.buf, true, win_config())
  apply_window_opts()

  state.job = vim.fn.jobstart(resolved_cmd(), {
    term = true,
    on_exit = function(job, code)
      vim.schedule(function()
        -- Ignore a stale exit from a previous session that has already been replaced.
        if state.job ~= job then
          return
        end
        teardown()
        if config.options.on_exit then
          config.options.on_exit(code)
        end
      end)
    end,
  })

  if state.job <= 0 then
    vim.notify("lazyjira: failed to start process", vim.log.levels.ERROR)
    teardown()
    return
  end

  set_keymaps()
  if config.options.start_insert then
    vim.cmd.startinsert()
  end
  if config.options.on_open then
    config.options.on_open(state)
  end
end

---Hide the window but keep the process and buffer alive.
function M.hide()
  if M.is_open() then
    vim.api.nvim_win_close(state.win, false)
    state.win = nil
  end
end

-- `close` is intentionally an alias of `hide`: it hides the window while the
-- lazyjira process keeps running. Quit the TUI itself with `q` inside lazyjira.
M.close = M.hide

---Toggle the window's visibility.
function M.toggle()
  if M.is_open() then
    M.hide()
  else
    M.open()
  end
end

---Internal: force-stop the session and tear everything down. Used by tests.
function M._reset()
  if state.job then
    pcall(vim.fn.jobstop, state.job)
  end
  teardown()
end

vim.api.nvim_create_autocmd("WinClosed", {
  group = augroup,
  callback = function(args)
    if state.win and tonumber(args.match) == state.win then
      state.win = nil
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    if M.is_open() then
      vim.api.nvim_win_set_config(state.win, win_config())
    end
  end,
})

return M
