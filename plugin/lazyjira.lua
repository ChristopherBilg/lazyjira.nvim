if vim.g.loaded_lazyjira then
  return
end
vim.g.loaded_lazyjira = true

vim.api.nvim_create_user_command("LazyJira", function()
  require("lazyjira").toggle()
end, { desc = "Toggle the lazyjira TUI" })
