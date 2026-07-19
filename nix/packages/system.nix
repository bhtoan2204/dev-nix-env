{ pkgs }:

let
  pythonEnvironment = pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
    pip
    black
    autopep8
    pycodestyle
  ]);
in
with pkgs; [
  git
  gh
  curl
  wget
  gnumake
  tree
  htop
  tmux
  screen
  unzip
  zip
  entr
  direnv
  jq
  yq-go
  ripgrep
  fd
  bat
  fzf

  protobuf
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

  pythonEnvironment
]
