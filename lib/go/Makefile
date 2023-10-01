all: build

########################################################################
##                             GOLANG                                 ##
########################################################################

# If GOPATH isn't defined then set its default location.
ifeq (,$(strip $(GOPATH)))
GOPATH := $(HOME)/go
else
# If GOPATH is already set then update GOPATH to be its own
# first element.
GOPATH := $(word 1,$(subst :, ,$(GOPATH)))
endif
export GOPATH

GOBIN := $(shell go env GOBIN)
ifeq (,$(strip $(GOBIN)))
GOBIN := $(GOPATH)/bin
endif


########################################################################
##                             PROTOC                                 ##
########################################################################

# Only set PROTOC_VER if it has an empty value.
ifeq (,$(strip $(PROTOC_VER)))
PROTOC_VER := 25.2
endif

PROTOC_OS := $(shell uname -s)
ifeq (Darwin,$(PROTOC_OS))
PROTOC_OS := osx
endif

PROTOC_ARCH := $(shell uname -m)
ifeq (i386,$(PROTOC_ARCH))
PROTOC_ARCH := x86_32
else ifeq (arm64,$(PROTOC_ARCH))
PROTOC_ARCH := aarch_64
endif

PROTOC := ./protoc
PROTOC_ZIP := protoc-$(PROTOC_VER)-$(PROTOC_OS)-$(PROTOC_ARCH).zip
PROTOC_URL := https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VER)/$(PROTOC_ZIP)
PROTOC_TMP_DIR := .protoc
PROTOC_TMP_BIN := $(PROTOC_TMP_DIR)/bin/protoc

$(PROTOC):
	-go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.32.0 && \
	  go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0 && \
	  mkdir -p "$(PROTOC_TMP_DIR)" && \
	  curl -L $(PROTOC_URL) -o "$(PROTOC_TMP_DIR)/$(PROTOC_ZIP)" && \
	  unzip "$(PROTOC_TMP_DIR)/$(PROTOC_ZIP)" -d "$(PROTOC_TMP_DIR)" && \
	  chmod 0755 "$(PROTOC_TMP_BIN)" && \
	  cp -f "$(PROTOC_TMP_BIN)" "$@"
	stat "$@" > /dev/null 2>&1


########################################################################
##                              PATH                                  ##
########################################################################

# Update PATH with GOBIN. This enables the protoc binary to discover
# the protoc-gen-go binary
export PATH := $(GOBIN):$(PATH)


########################################################################
##                              BUILD                                 ##
########################################################################
CSI_PROTO := ../../csi.proto
CSI_PKG_ROOT := github.com/container-storage-interface/spec
CSI_PKG_SUB := $(shell cat $(CSI_PROTO) | sed -nE -e 's/^package.([^;]*).v[0-9]+;$$/\1/p'|tr '.' '/')
CSI_BUILD := $(CSI_PKG_SUB)/.build
CSI_GO := $(CSI_PKG_SUB)/csi.pb.go
CSI_GRPC := $(CSI_PKG_SUB)/csi_grpc.pb.go
CSI_GRPC_TMP := $(CSI_BUILD)/$(CSI_PKG_ROOT)/lib/go/$(CSI_PKG_SUB)/csi_grpc.pb.go
CSI_GO_TMP := $(CSI_BUILD)/$(CSI_PKG_ROOT)/lib/go/$(CSI_PKG_SUB)/csi.pb.go

# This recipe generates the go language bindings to a temp area.
$(CSI_GO_TMP) $(CSI_GRPC_TMP): INCLUDE := -I../.. -I$(PROTOC_TMP_DIR)/include
$(CSI_GO_TMP) $(CSI_GRPC_TMP): $(CSI_PROTO) | $(PROTOC)
	@mkdir -p "$(@D)"
	$(PROTOC) $(INCLUDE) --go-grpc_out=$(CSI_BUILD) --go_out=$(CSI_BUILD) \
		--go_opt=Mgoogle/protobuf/descriptor.proto=github.com/golang/protobuf/protoc-gen-go/descriptor \
		--go_opt=Mgoogle/protobuf/wrappers.proto=github.com/golang/protobuf/ptypes/wrappers \
		"$(<F)"

# The temp language bindings are compared to the ones that are
# versioned. If they are different then it means the language
# bindings were not updated prior to being committed.
$(CSI_GO): $(CSI_GO_TMP)
ifeq (true,$(GITHUB_ACTIONS))
	diff "$@" "$?"
else
	@mkdir -p "$(@D)"
	diff "$@" "$?" > /dev/null 2>&1 || cp -f "$?" "$@"
endif
$(CSI_GRPC): $(CSI_GRPC_TMP)
ifeq (true,$(GITHUB_ACTIONS))
	diff "$@" "$?"
else
	@mkdir -p "$(@D)"
	diff "$@" "$?" > /dev/null 2>&1 || cp -f "$?" "$@"
endif


build: $(CSI_GO) $(CSI_GRPC)

clean:
	go clean -i ./...
	rm -rf "$(CSI_GO)" "$(CSI_GRPC)" "$(CSI_BUILD)"

clobber: clean
	rm -fr "$(PROTOC)" "$(CSI_PKG_SUB)"

.PHONY: clean clobber
