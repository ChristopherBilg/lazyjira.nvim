# Contributing

Thanks for contributing to lazyjira.nvim!

## Development

Requirements: Neovim 0.11+, `stylua`, `selene`, `lua-language-server`.

Common tasks (see the `Makefile`):

- `make format` — format with stylua
- `make lint` — stylua --check + selene
- `make typecheck` — lua-language-server diagnostics
- `make test` — run the mini.test suite headlessly
- `make all` — lint + typecheck + test

## Commit messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/)
(`feat:`, `fix:`, `docs:`, `ci:`, `chore:`, etc.). Releases and the changelog are
automated by release-please based on these messages.
