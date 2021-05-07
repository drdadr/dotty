.PHONY: test

export PATH := $(PWD)/bats/bin:$(PATH)

test: bats
	bats ${CI:+--tap} test

bats/: test/test_helper/bats-support test/test_helper/bats-assert test/test_helper/bats-file
	rm -rf $@
	mkdir -p $@
	git clone --depth 1 --branch v1.2.1 https://github.com/bats-core/bats-core.git bats

test/test_helper/bats-support:
	rm -rf $@
	mkdir -p $@
	git clone --depth 1 --branch v0.3.0 https://github.com/bats-core/bats-support $@

test/test_helper/bats-assert:
	rm -rf $@
	mkdir -p $@
	git clone --depth 1 --branch v0.3.0 https://github.com/bats-core/bats-assert $@

test/test_helper/bats-file:
	rm -rf $@
	mkdir -p $@
	git clone --depth 1 --branch v0.3.0 https://github.com/bats-core/bats-file $@
