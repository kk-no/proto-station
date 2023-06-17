.DEFAULT_GOAL := gen

BIN := $(CURDIR)/.bin
GEN := $(CURDIR)/gen

PATH := ${PATH}:$(BIN)
UNAME_OS := $(shell uname -s)
UNAME_ARCH := $(shell uname -m)

$(BIN):
	mkdir -p $(BIN)

BUF := $(BIN)/buf
BUF_VERSION := 1.7.0
$(BUF): | $(BIN)
	curl -sSL \
		"https://github.com/bufbuild/buf/releases/download/v$(BUF_VERSION)/buf-$(UNAME_OS)-$(UNAME_ARCH)" \
		-o "$(BIN)/buf"
	chmod +x "$(BIN)/buf"

.PHONY: gen
gen: $(BUF) $(PROTOC) $(PROTOC_GEN_GO) $(PROTOC_GEN_GO_GRPC) $(PROTOC_GEN_GRPC_GATEWAY) $(PROTOC_GEN_DOC) ## generate all files
	@$(MAKE) gen-go

.PHONY: gen-go
gen-go: $(BUF) $(PROTOC) $(PROTOC_GEN_GO) ## generate go files
	@rm -rf $(GEN)/go
	@mkdir -p $(GEN)/go
	@$(BIN)/buf generate

.PHONY: sync
sync: ## code sync to terminal
	@make
	@git clone https://github.com/kk-no/proto-terminal.git
	@cp -r $(GEN)/go/ proto-terminal/
	@cd proto-terminal && \
		git add -A . && \
		git commit -m "generate from proto" --allow-empty && \
		git push -f
	@rm -rf proto-terminal

fmt: $(BUF) ## format proto files
	@$(BIN)/buf format -w

lint: $(BUF) ## lint proto files
	@$(BIN)/buf lint

help: ## display this help screen
	@grep -E '^[a-zA-Z/_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'