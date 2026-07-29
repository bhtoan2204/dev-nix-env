{ pkgs }:

with pkgs; [
  deadcode
  go
  govulncheck
  gopls
  golangci-lint
  grpcurl
  mockgen
  nilaway
  protoc-gen-go
  protoc-gen-go-grpc
  staticcheck
  gotools
  gotests
  go-migrate
]
