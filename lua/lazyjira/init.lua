local config = require("lazyjira.config")
local terminal = require("lazyjira.terminal")

local M = {}

---Apply user configuration. Optional — the plugin works with defaults.
---@param opts? lazyjira.Config
function M.setup(opts)
  config.merge(opts)
end

---Open (or reveal) the lazyjira window.
function M.open()
  terminal.open()
end

---Hide the lazyjira window (the process keeps running).
function M.close()
  terminal.hide()
end

---Toggle the lazyjira window.
function M.toggle()
  terminal.toggle()
end

return M
