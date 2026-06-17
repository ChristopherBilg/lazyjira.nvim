local config = require("lazyjira.config")

local M = {}

---@param cmd string|string[]
---@return string
local function cmd_name(cmd)
  return type(cmd) == "table" and cmd[1] or cmd
end

function M.check()
  vim.health.start("lazyjira")

  if vim.fn.has("nvim-0.11") == 1 then
    vim.health.ok("Neovim >= 0.11")
  else
    vim.health.warn("Neovim 0.11+ is recommended; some features may be unavailable")
  end

  local name = cmd_name(config.options.cmd)
  if vim.fn.executable(name) == 1 then
    local version = vim.trim(vim.fn.system({ name, "--version" }) or "")
    vim.health.ok(("`%s` found (%s)"):format(name, version ~= "" and version or "version unknown"))
  else
    vim.health.error(("`%s` not found in PATH"):format(name), {
      "Install lazyjira: https://github.com/textfuel/lazyjira",
    })
  end
end

return M
