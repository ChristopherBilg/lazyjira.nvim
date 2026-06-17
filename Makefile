.PHONY: all format lint typecheck test doc

all: lint typecheck test

format:
	stylua lua/ plugin/ tests/

lint:
	stylua --check lua/ plugin/ tests/
	selene lua/ plugin/

typecheck:
	./scripts/typecheck.sh

test:
	nvim --headless --noplugin -u tests/minimal_init.lua -c "lua MiniTest.run()"

doc:
	nvim --headless -c "helptags doc" -c "qa!"
