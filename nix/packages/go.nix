{ pkgs }:

with pkgs; [
  go
  govulncheck
  gopls
  golangci-lint
  grpcurl
  mockgen
  nilaway
  protoc-gen-go
  protoc-gen-go-grpc
  go-tools
  gotools
  gotests
  go-migrate
]
