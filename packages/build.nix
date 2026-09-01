{ pkgs }:

let
  pythonEnvironment = pkgs.python3.withPackages (
    pythonPackages: with pythonPackages; [
      pip
      black
      autopep8
      pycodestyle
    ]
  );
in
with pkgs;
[
  clang
  gnumake
  cmake
  ninja
  pkg-config
  autoconf
  autoconf-archive
  automake
  libtool
  m4
  bison
  openssl
  nixfmt
  shellcheck
  shfmt
  stylua
  pythonEnvironment
]
