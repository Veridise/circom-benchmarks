CARGO=cargo
LIT=lit

.PHONY: test build

test:
	@$(LIT) tests

build:
	@$(CARGO) -C circom build