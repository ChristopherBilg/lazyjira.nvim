.PHONY: all format lint typecheck test doc

all: lint typecheck test

format:
	stylua lua/ plugin/ tests/

lint:
	stylua --check lua/ plugin/ tests/
	selene lua/ plugin/

typecheck:
	lua-language-server --check . --checklevel=Warning --logpath=.luals-log
	@if [ -f .luals-log/check.json ] && [ "$$(cat .luals-log/check.json)" != "[]" ]; then \
		cat .luals-log/check.json; \
		exit 1; \
	fi

test:
	nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"

doc:
	nvim --headless -c "helptags doc" -c "qa!"
