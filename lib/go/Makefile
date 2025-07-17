all: build

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

PROTOC_ZIP := protoc-$(PROTOC_VER)-$(PROTOC_OS)-$(PROTOC_ARCH).zip
PROTOC_URL := https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VER)/$(PROTOC_ZIP)
PROTOC_TMP_DIR := .protoc
PROTOC := $(PROTOC_TMP_DIR)/bin/protoc

$(PROTOC):
	-mkdir -p "$(PROTOC_TMP_DIR)" && \
	  curl -L $(PROTOC_URL) -o "$(PROTOC_TMP_DIR)/$(PROTOC_ZIP)" && \
	  unzip "$(PROTOC_TMP_DIR)/$(PROTOC_ZIP)" -d "$(PROTOC_TMP_DIR)" && \
	  chmod 0755 "$@"
	stat "$@" > /dev/null 2>&1

PROTOC_ALL := protoc-gen-go protoc-gen-go-grpc $(PROTOC)

########################################################################
##                              BUILD                                 ##
########################################################################
CSI_PROTO := ../../csi.proto
CSI_PKG_SUB := csi
CSI_GO := $(CSI_PKG_SUB)/csi.pb.go
CSI_GRPC := $(CSI_PKG_SUB)/csi_grpc.pb.go

# This recipe generates the go language bindings
$(CSI_GO) $(CSI_GRPC): $(CSI_PROTO) $(PROTOC_ALL) ../../go.mod
	@mkdir -p "$(@D)"
	$(PROTOC) --plugin=./protoc-gen-go --plugin=./protoc-gen-go-grpc \
		-I../.. --go-grpc_out=$(CSI_PKG_SUB) --go_out=$(CSI_PKG_SUB) \
		--go_opt=paths=source_relative --go-grpc_opt=paths=source_relative \
		"$(<F)"

build: $(CSI_GO) $(CSI_GRPC)

clean:
	go clean -i ./...
	rm -rf "$(CSI_PKG_SUB)"

clobber: clean
	rm -fr "$(PROTOC_TMP_DIR)"

.PHONY: clean clobber
