#!/usr/bin/env bash
# Generates Go gRPC stubs from proto/*.proto into internal/pb/.
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p internal/pb
protoc -I proto \
  --go_out=.      --go_opt=module=georgia-travel-guide \
  --go-grpc_out=. --go-grpc_opt=module=georgia-travel-guide \
  proto/city.proto proto/places.proto proto/route.proto proto/favorite.proto proto/auth.proto
echo "proto stubs generated in internal/pb/"
