local config = require("lazyjira.config")
local eq = MiniTest.expect.equality
local expect_error = MiniTest.expect.error

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      config.options = vim.deepcopy(config.defaults)
    end,
  },
})

T["merge() returns defaults when given no opts"] = function()
  local merged = config.merge()
  eq(merged.cmd, "lazyjira")
  eq(merged.window.width, 0.9)
  eq(merged.start_insert, true)
end

T["merge() overrides only the provided keys"] = function()
  local merged = config.merge({ window = { width = 0.5 } })
  eq(merged.window.width, 0.5)
  eq(merged.window.height, 0.9)
  eq(merged.window.border, "rounded")
end

T["merge() stores the result in config.options"] = function()
  config.merge({ start_insert = false })
  eq(config.options.start_insert, false)
end

T["merge() rejects a non-table argument"] = function()
  expect_error(function()
    ---@diagnostic disable-next-line: param-type-mismatch
    config.merge("nope")
  end)
end

T["merge() rejects a bad cmd type"] = function()
  expect_error(function()
    config.merge({ cmd = 42 })
  end)
end

T["merge() warns on unknown top-level keys"] = function()
  local warned = false
  local original = vim.notify
  vim.notify = function(msg, level)
    if level == vim.log.levels.WARN and tostring(msg):find("unknown config key") then
      warned = true
    end
  end
  config.merge({ unknown_key = true })
  vim.notify = original
  eq(warned, true)
end

T["merge() replaces args wholesale rather than index-merging"] = function()
  local merged = config.merge({ args = { "--demo" } })
  eq(merged.args, { "--demo" })
end

return T
