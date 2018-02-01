#!/bin/sh

# Check to see if there is any content in STDIN. If nothing is read
# after 1 second, then exit with an error.
if IFS= read -rt 1 line; then
  echo "$line" > csi.spec
else
  echo "usage: cat spec.md | docker run -i golang/csi"
  exit 1
fi

while IFS= read -r line; do
  echo "$line" >> csi.spec
done

sed -ne '/```protobuf$/,/```$/ p' < csi.spec | \
  sed -e 's@^```.*$@////////@g' > csi.proto

if [ "$1" = "proto" ]; then
  cat csi.proto
else
  protoc -I . --go_out=plugins=grpc:. csi.proto
  cat csi.pb.go
fi
