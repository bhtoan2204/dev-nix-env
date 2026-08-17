{ pkgs }:

with pkgs;
[
  go
  gopls
  delve
  golangci-lint
  gofumpt
  govulncheck
  gotools
  go-tools
  mockgen
  nilaway
  gotests
  go-migrate
  protoc-gen-go
  protoc-gen-go-grpc
]
