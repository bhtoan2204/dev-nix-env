{ pkgs }:

with pkgs;
[
  rustc
  cargo
  rustfmt
  clippy
  rust-analyzer
  cargo-edit
  cargo-watch
  cargo-audit
  cargo-nextest
  cargo-expand
  cargo-llvm-cov
  sccache
]
