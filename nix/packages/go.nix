{ pkgs }:

with pkgs; [
  go
  gopls
  golangci-lint
  grpcurl
  mockgen
  protoc-gen-go
  protoc-gen-go-grpc
  gotools
  gotests
  go-migrate
]
