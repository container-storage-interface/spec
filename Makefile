all: build

CSI_SPEC := spec.md
CSI_PROTO := csi.proto

# the target for building the temporary csi protobuf file.
# the temporary file is not versioned and thus will always be
# built on travis-ci
$(CSI_PROTO).tmp: $(CSI_SPEC)
	cat $? | \
	  sed -n -e '/```protobuf$$/,/```$$/ p' | \
	  sed -e 's@^```.*$$@////////@g' > $@

# the target for building the csi protobuf file. this target
# depends on the temp file, which is not versioned. therefore
# when built on travis-ci, the temp file is always built and
# will trigger this target. on travis-ci the temp file is
# compared with the real file and if they differ the build
# will fail. locally the temp file is simply copied over
# the real file
$(CSI_PROTO): $(CSI_PROTO).tmp
ifeq (true,$(TRAVIS))
	diff "$@" "$?"
else
	cp -f "$?" "$@"
endif

build: $(CSI_PROTO)

# if this is not running on travis-ci then for sake of convenience
# go ahead and update the language bindings as well
ifneq (true,$(TRAVIS))
build:
	$(MAKE) -C lib/go
	$(MAKE) -C lib/cxx
endif

clean:
	rm -f $(CSI_PROTO).tmp

clobber: clean
	rm -f $(CSI_PROTO)

.PHONY: clean clobber
