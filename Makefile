all: build

include csi.mk

build: $(CSI_PROTO) $(CSI_GOSRC)

clean:
	rm -f $(CSI_PROTO) $(CSI_GOSRC)
