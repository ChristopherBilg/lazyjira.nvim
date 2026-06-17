local config = require("lazyjira.config")
local terminal = require("lazyjira.terminal")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      config.options = vim.deepcopy(config.defaults)
      config.options.cmd = { "tail", "-f", "/dev/null" } -- harmless long-running process
      config.options.start_insert = false
      terminal._reset()
    end,
    post_case = function()
      terminal._reset()
    end,
  },
})

T["open() opens a window for the session"] = function()
  terminal.open()
  eq(terminal.is_open(), true)
end

T["hide() closes the window but preserves the buffer"] = function()
  terminal.open()
  local buf1 = vim.api.nvim_get_current_buf()
  terminal.hide()
  eq(terminal.is_open(), false)
  eq(vim.api.nvim_buf_is_valid(buf1), true)
  terminal.open()
  local buf2 = vim.api.nvim_get_current_buf()
  eq(buf1, buf2) -- same buffer reused => state preserved
end

T["toggle() flips visibility"] = function()
  eq(terminal.is_open(), false)
  terminal.toggle()
  eq(terminal.is_open(), true)
  terminal.toggle()
  eq(terminal.is_open(), false)
end

T["open() with a missing binary notifies and does not open"] = function()
  config.options.cmd = "definitely-not-a-real-binary-xyz"
  local notified = false
  local original = vim.notify
  ---@diagnostic disable-next-line: duplicate-set-field
  vim.notify = function()
    notified = true
  end
  local ok = pcall(terminal.open)
  vim.notify = original
  eq(ok, true)
  eq(notified, true)
  eq(terminal.is_open(), false)
end

T["WinClosed syncs state without killing the job"] = function()
  terminal.open()
  local buf1 = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_close(win, true) -- simulate the user pressing :q on the float
  eq(terminal.is_open(), false)
  terminal.open() -- should reuse the existing session, not spawn a new one
  local buf2 = vim.api.nvim_get_current_buf()
  eq(buf1, buf2)
end

T["on_open fires on both a fresh open and a reveal"] = function()
  local count = 0
  config.options.on_open = function()
    count = count + 1
  end
  terminal.open() -- fresh open
  terminal.hide()
  terminal.open() -- reveal (new window onto the existing buffer)
  eq(count, 2)
end

return T
