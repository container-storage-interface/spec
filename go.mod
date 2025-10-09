module github.com/container-storage-interface/spec

go 1.24

tool (
	google.golang.org/grpc/cmd/protoc-gen-go-grpc
	google.golang.org/protobuf/cmd/protoc-gen-go
)

require (
	google.golang.org/grpc v1.57.1
	google.golang.org/protobuf v1.33.0
)

require (
	github.com/golang/protobuf v1.5.4 // indirect
	golang.org/x/net v0.38.0 // indirect
	golang.org/x/sys v0.31.0 // indirect
	golang.org/x/text v0.23.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20230803162519-f966b187b2e5 // indirect
	google.golang.org/grpc/cmd/protoc-gen-go-grpc v1.3.0 // indirect
)
