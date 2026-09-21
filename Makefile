.PHONY: test test-scala check

VIM ?= vim
SCALAC ?= scalac

test:
	$(VIM) --clean -Nu NONE -n -es -S test/run.vim

test-scala:
	@classes=$$(mktemp -d); trap 'rm -rf "$$classes"' EXIT; \
		$(SCALAC) -source 3.9 -d "$$classes" test/fixtures/Valid.scala

check: test
	git diff --check
