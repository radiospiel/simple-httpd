.PHONY: test

test:
	rspec

.PHONY: fulltest
fulltest:
	rspec
	PRELOAD_GEMS=puma rspec
