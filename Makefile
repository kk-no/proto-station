.DEFAULT_GOAL := gen

BIN := $(CURDIR)/.bin
GEN := $(CURDIR)/gen

UNAME_OS := $(shell uname -s)
UNAME_ARCH := $(shell uname -m)

$(BIN):
	mkdir -p $(BIN)

PROTOC := $(BIN)/protoc
PROTOC_VERSION := 3.14.0
PROTOC_ZIP := protoc-$(PROTOC_VERSION)-$(UNAME_OS)-$(UNAME_ARCH).zip
ifeq "$(UNAME_OS)" "Darwin"
	PROTOC_ZIP=protoc-$(PROTOC_VERSION)-osx-$(UNAME_ARCH).zip
endif

$(PROTOC): | $(BIN)
	curl -sSOL \
		"https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/$(PROTOC_ZIP)"
	unzip -j -o $(PROTOC_ZIP) -d $(BIN) bin/protoc
	unzip -o $(PROTOC_ZIP) -d $(BIN) "include/*"
	rm -f $(PROTOC_ZIP)

BUF := $(BIN)/buf
BUF_VERSION := 0.33.0
$(BUF): | $(BIN)
	curl -sSL \
		"https://github.com/bufbuild/buf/releases/download/v$(BUF_VERSION)/buf-$(UNAME_OS)-$(UNAME_ARCH)" \
		-o "$(BIN)/buf"
	chmod +x "$(BIN)/buf"

PROTOC_GEN_GO := $(BIN)/protoc-gen-go
$(PROTOC_GEN_GO): | $(BIN)
	go build -o $(PROTOC_GEN_GO) google.golang.org/protobuf/cmd/protoc-gen-go

PROTOC_GEN_GO_GRPC := $(BIN)/protoc-gen-go-grpc
$(PROTOC_GEN_GO_GRPC): | $(BIN)
	go build -o $(PROTOC_GEN_GO_GRPC) google.golang.org/grpc/cmd/protoc-gen-go-grpc

PROTOC_GEN_GRPC_GATEWAY := $(BIN)/protoc-gen-grpc-gateway
$(PROTOC_GEN_GRPC_GATEWAY): | $(BIN)
	go build -o $(PROTOC_GEN_GRPC_GATEWAY) github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-grpc-gateway

PROTOC_GEN_DOC := $(BIN)/protoc-gen-doc
$(PROTOC_GEN_DOC): | $(BIN)
	go build -o $(PROTOC_GEN_DOC) github.com/pseudomuto/protoc-gen-doc/cmd/protoc-gen-doc

PROTOC_OPTION := --descriptor_set_in=/dev/stdin
PROTOC_OPTION_GO := --go_out=$(GEN)/go --go_opt=paths=source_relative --go-grpc_out=$(GEN)/go --go-grpc_opt=require_unimplemented_servers=true,paths=source_relative
PROTOC_OPTION_GATEWAY := --grpc-gateway_out=$(GEN)/go --grpc-gateway_opt=paths=source_relative
PROTOC_OPTION_DOC := --plugin=protoc-gen-doc=$(PROTOC_GEN_DOC) --doc_out=$(GEN)/doc --doc_opt=html,index.html
TARGETS := $(shell find proto -name *.proto | sed -e 's/^proto\///')

.PHONY: gen
gen: $(BUF) $(PROTOC) $(PROTOC_GEN_GO) $(PROTOC_GEN_GO_GRPC) $(PROTOC_GEN_GRPC_GATEWAY) $(PROTOC_GEN_DOC) ## generate all files
	@$(MAKE) gen-doc
	@$(MAKE) gen-go

.PHONY: gen-doc
gen-doc: $(BUF) $(PROTOC) $(PROTOC_GEN_DOC) ## generate doc files
	@rm -rf $(GEN)/doc
	@mkdir -p $(GEN)/doc
	@$(BIN)/buf build -o - | $(BIN)/protoc $(PROTOC_OPTION) $(PROTOC_OPTION_DOC) $(TARGETS)

.PHONY: gen-go
gen-go: $(BUF) $(PROTOC) $(PROTOC_GEN_GO) ## generate go files
	@rm -rf $(GEN)/go
	@mkdir -p $(GEN)/go
	@$(BIN)/buf build -o - | $(BIN)/protoc $(PROTOC_OPTION) $(PROTOC_OPTION_GO) $(PROTOC_OPTION_GATEWAY) $(TARGETS)

.PHONY: sync
sync: ## code sync to terminal
	@git clone https://github.com/kk-no/proto-terminal.git
	@cp -r $(GEN)/go/ proto-terminal/
	@cd proto-terminal && \
		git add -A . && \
		git commit -m "generate from proto" --allow-empty && \
		git push -f
	@rm -rf proto-terminal

lint: $(BUF) ## buf lint proto files
	@$(BIN)/buf check lint

help: ## display this help screen
	@grep -E '^[a-zA-Z/_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'