.PHONY: test

export MIX_ENV ?= dev

default: help

#help: @ Shows help topics
help:
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#'  | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}'

#test: @ Run mix tests
test: MIX_ENV=test
test: SHELL:=/bin/bash
test:
	source .env && mix test
