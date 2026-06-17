# lazyjira.nvim

[![CI](https://github.com/Christopherbilg/lazyjira.nvim/actions/workflows/ci.yml/badge.svg)](https://github.com/Christopherbilg/lazyjira.nvim/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue)](./LICENSE)

Run the [`lazyjira`](https://github.com/textfuel/lazyjira) TUI in a floating
window inside Neovim, a single reusable instance you toggle open and closed.
Zero runtime dependencies.

Inspired by [lazygit.nvim](https://github.com/kdheepak/lazygit.nvim) and
[lazydocker.nvim](https://github.com/crnvl96/lazydocker.nvim).

![Screenshot of lazyjira.nvim inside of neovim](/screenshot.png)

## Requirements

- Neovim >= 0.11
- The [`lazyjira`](https://github.com/textfuel/lazyjira) executable in your `PATH`

Run `:checkhealth lazyjira` to verify.

## Installation

With [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "Christopherbilg/lazyjira.nvim",
  cmd = "LazyJira",
  keys = {
    { "<leader>j", "<cmd>LazyJira<cr>", desc = "lazyjira" },
  },
  opts = {},
}
```

`opts = {}` calls `setup()` for you. The plugin also works with zero config.

## Usage

- `:LazyJira` toggles the window.
- Lua API: `require("lazyjira").open() / .close() / .toggle()`.

Hiding the window keeps the `lazyjira` process running; pressing `q` inside the
TUI quits it and closes the window.

## Configuration

Defaults:

```lua
require("lazyjira").setup({
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
  keymaps = { close = false },
  on_open = nil,
  on_exit = nil,
})
```

| Option | Default | Description |
| --- | --- | --- |
| `cmd` | `"lazyjira"` | Command (string or list) used to launch the TUI. |
| `args` | `{}` | Extra arguments appended to `cmd` (e.g. `{ "--demo" }`). |
| `window.width` / `.height` | `0.9` | `<= 1` = fraction of the editor; `> 1` = absolute size. |
| `window.border` | `"rounded"` | Any `nvim_open_win()` border value. |
| `window.title` / `.title_pos` | `" lazyjira "` / `"center"` | Float title. |
| `window.zindex` / `.winblend` | `50` / `0` | Float z-index / transparency. |
| `start_insert` | `true` | Enter terminal-mode on open. |
| `keymaps.close` | `false` | Buffer-local "hide window" mapping, or `false`. |
| `on_open` / `on_exit` | `nil` | Lifecycle hooks. |

## License

MIT
