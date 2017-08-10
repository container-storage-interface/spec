all: build

include ../../protoc.mk

# if GOPATH isn't defined then set its default location
ifeq (,$(strip $(GOPATH)))
GOPATH := $(HOME)/go
else
# if GOPATH is arleady update GOPATH to be its first element
GOPATH := $(word 1,$(subst :, ,$(GOPATH)))
endif
export GOPATH

# update PATH with the GOPATH/bin directory
PATH := $(GOPATH)/bin:$(PATH)
export PATH

# the recipe for getting and installing the go plug-in for protoc
PROTOC_GEN_GO := $(GOPATH)/bin/protoc-gen-go
$(PROTOC_GEN_GO):
	go get github.com/golang/protobuf/protoc-gen-go && \
	go install github.com/golang/protobuf/protoc-gen-go

# a list of the go packages required to generate the
# go bindings for the csi specification
PROTOC_GO_PKGS += google.golang.org/grpc
PROTOC_GO_PKGS += github.com/golang/protobuf/proto

# the following recipe downloads the go packages necessary
# to generate the go language bindings
PROTOC_GO_PKGS := $(addprefix $(GOPATH)/src/,$(PROTOC_GO_PKGS))
$(PROTOC_GO_PKGS):
	go get $(@:$(GOPATH)/src/%=%)

PROTOC_GO := $(PROTOC_GO_PKGS) $(PROTOC_GEN_GO)
protoc-go: $(PROTOC_GO)

CSI_GO := csi.pb.go
CSI_PROTO := ../../csi.proto
CSI_GO_TMP := .build/csi.pb.go

# this recipe generates the go language bindings to a temp area
$(CSI_GO_TMP): $(CSI_PROTO)
	mkdir -p "$(@D)" && \
	$(PROTOC) -I "$(<D)" --go_out=plugins=grpc:"$(@D)" "$<"

# the temp language bindings are compared to the ones that are
# versioned. if they are different then it means the language
# bindings were not updated prior to being committed
$(CSI_GO): $(CSI_GO_TMP) | $(PROTOC_GO)
ifeq (true,$(TRAVIS))
	diff "$@" "$?"
else
	cp -f "$?" "$@"
endif

build: $(CSI_GO)

clean:
	go clean -i -v

.PHONY: clean
