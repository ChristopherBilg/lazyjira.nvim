-- Minimal init for headless mini.test runs.
-- Bootstraps mini.nvim (provides mini.test) into a scratch dir, then sets up MiniTest.
local function bootstrap()
  local deps = vim.fn.stdpath("data") .. "/site/pack/deps/start"
  local mini_path = deps .. "/mini.nvim"
  if vim.fn.isdirectory(mini_path) == 0 then
    vim.fn.mkdir(deps, "p")
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/echasnovski/mini.nvim",
      mini_path,
    })
  end
  vim.opt.rtp:prepend(mini_path)
  vim.opt.rtp:prepend(vim.fn.getcwd())
end

bootstrap()
require("mini.test").setup()
