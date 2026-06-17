local lazyjira = require("lazyjira")
local config = require("lazyjira.config")
local eq = MiniTest.expect.equality

local T = MiniTest.new_set({
  hooks = {
    pre_case = function()
      config.options = vim.deepcopy(config.defaults)
    end,
  },
})

T["setup() merges and stores options"] = function()
  lazyjira.setup({ start_insert = false, window = { width = 0.7 } })
  eq(config.options.start_insert, false)
  eq(config.options.window.width, 0.7)
  eq(config.options.window.height, 0.9)
end

T["exposes open/close/toggle functions"] = function()
  eq(type(lazyjira.open), "function")
  eq(type(lazyjira.close), "function")
  eq(type(lazyjira.toggle), "function")
end

T["plugin file registers the :LazyJira command"] = function()
  vim.cmd("runtime plugin/lazyjira.lua")
  eq(vim.fn.exists(":LazyJira"), 2)
end

return T
