.DEFAULT_GOAL := help

API_KEY := # API key for the OpenSubtitles.

.PHONY: build
build: # Build the osub binary. API key is reauired.
ifdef API_KEY
	@go build \
		-ldflags "-X 'vanyauhalin/osub/pkg/rest.apiKey=$(API_KEY)'" \
		-o ./.build/osub ./cmd/osub/main.go
else
	@echo "error: API_KEY is not set."
	@exit 1
endif

.PHONY: help
help: # Show help information.
	@echo "reciepts:"
	@grep --extended-regexp "^[a-z-]+: #" "$(MAKEFILE_LIST)" | \
		awk 'BEGIN {FS = ": # "}; {printf "  %-10s  %s\n", $$1, $$2}'
	@echo ""
	@echo "arguments:"
	@grep --extended-regexp "^[A-Z_]+ := #" "$(MAKEFILE_LIST)" | \
		awk 'BEGIN {FS = " := # "}; {printf "  %-10s  %s\n", $$1, $$2}'

.PHONY: lint
lint: # Lint the source code.
	@golangci-lint run

.PHONY: test
test: # Run tests.
	@go test -v ./...
