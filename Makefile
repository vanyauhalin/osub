.PHONY: build clean dev help install lint test version

BUILD_VERSION := 0.3.0
MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))

API_KEY :=
target :=

help:
	@echo "OVERVIEW: Welcome to the vanyauhalin/osub sources."
	@echo ""
	@echo "USAGE: make <subcommand> [argument=value]"
	@echo ""
	@echo "SUBCOMMANDS:"
	@echo "  build       Build the osub via Tuist."
	@echo "  clean       Clean generated Tuist files."
	@echo "  dev         Generate a development workspace via Tuist."
	@echo "  help        Show this message."
	@echo "  install     Install dependencies via Tuist."
	@echo "  lint        Lint the osub via SwiftLint."
	@echo "  test        Test the osub via Tuist."
	@echo "  version     Print the current osub version."
	@echo ""
	@echo "ARGUMENTS:"
	@echo "  API_KEY     Specify a API key for the build command."
	@echo "  target      Specify a target for the lint command."

define guard_tuist
	$(if $(shell command -v tuist),,echo "Tuist is not installed, please visit https://tuist.io/ to learn how to install it." && exit 1)
endef

build: \
	export TUIST_API_KEY := $(API_KEY)
	export TUIST_BUILD_VERSION := $(BUILD_VERSION)
	export TUIST_MAKEFILE_PATH := $(MAKEFILE_PATH)
build:
	@$(call guard_tuist)
	@tuist build osub \
		--configuration Release \
		--build-output-path .build \
		--generate

clean:
	@rm -rf \
		*.xcodeproj \
		*.xcworkspace \
		.build \
		Derived

dev: \
	export TUIST_MAKEFILE_PATH := $(MAKEFILE_PATH)
dev:
	@$(call guard_tuist)
	@tuist generate

install:
	@$(call guard_tuist)
	@tuist fetch

lint: \
	export PATH := $(PATH):/opt/homebrew/bin
lint:
	@if ! command -v swiftlint > /dev/null; then \
		echo "warning: SwiftLint is not installed, please visit https://realm.github.io/SwiftLint to see how to install it."; \
	else \
		swiftlint lint \
			--config $(MAKEFILE_DIR).swiftlint.yml \
			$(MAKEFILE_DIR)$(target); \
	fi

test: \
	export TUIST_MAKEFILE_PATH := $(MAKEFILE_PATH)
test:
	@$(call guard_tuist)
	@tuist test

version:
	@echo $(BUILD_VERSION)
