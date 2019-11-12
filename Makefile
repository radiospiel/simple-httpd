.PHONY: test

test:
	rspec

.PHONY: fulltest
fulltest:
	rspec
	PRELOAD_SERVER_GEM=puma rspec
