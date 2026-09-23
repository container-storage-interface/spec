FROM golang:1.12.7 

RUN apt-get update && apt-get install -y \
  unzip \
  && rm -rf /var/lib/apt/lists/*

ENV PROTOC_VER "3.9.1"
ENV PROTOC_ZIP "protoc-${PROTOC_VER}-linux-x86_64.zip"
RUN curl -OL "https://github.com/google/protobuf/releases/download/v${PROTOC_VER}/${PROTOC_ZIP}" \
  && unzip -o "${PROTOC_ZIP}" -d /usr/local bin/protoc \
  && unzip -o "${PROTOC_ZIP}" -d /usr/local include/* \
  && rm "${PROTOC_ZIP}" 

ENV PROTOC_GEN_GO_VERSION "v1.3.2" 
RUN go get -d -u github.com/golang/protobuf/protoc-gen-go \
  && git -C "$(go env GOPATH)"/src/github.com/golang/protobuf checkout "${PROTOC_GEN_GO_VERSION}" \
  && go install github.com/golang/protobuf/protoc-gen-go

