#!/usr/bin/env bash
# Gỡ tất cả tool đang cài ngoài Nix.
# CHẠY SAU KHI: nix installed + `nix develop` chạy được thành công.
set -euo pipefail

echo ">>> [1/7] Gỡ apt dev tools..."
sudo apt-get remove -y \
  golang-go golang-src golang-1.18-go golang-1.18-src \
  gh \
  k9s kafkacat fd-find entr ripgrep htop tree screen \
  terraform yt-dlp mpv stripe \
  protobuf-compiler \
  cmake ninja-build \
  autoconf autoconf-archive automake libtool m4 bison \
  python3.11 python3.11-dev python3.11-venv python3-pip \
  maven \
  wkhtmltox mingw-w64 qt6-base-dev \
  2>/dev/null || true  # bỏ qua nếu package nào đó không có

echo ">>> [2/7] Gỡ Docker..."
sudo apt-get remove -y \
  docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin \
  2>/dev/null || true
sudo rm -rf /var/lib/docker /etc/docker
sudo rm -f /usr/bin/docker-compose

echo ">>> [3/7] Autoremove orphaned deps..."
sudo apt-get autoremove -y

echo ">>> [4/7] Gỡ binaries cài thủ công..."
sudo rm -f /usr/local/bin/helm
sudo rm -f /usr/local/bin/protoc
sudo rm -rf /usr/local/include/google   # protobuf headers

echo ">>> [5/7] Gỡ Go-installed binaries (~go/bin)..."
rm -rf "$HOME/go/bin"

echo ">>> [6/7] Gỡ pip-installed tools (~/.local/bin)..."
rm -f \
  "$HOME/.local/bin/autopep8" \
  "$HOME/.local/bin/black" \
  "$HOME/.local/bin/blackd" \
  "$HOME/.local/bin/pycodestyle" \
  "$HOME/.local/bin/flask" \
  "$HOME/.local/bin/normalizer" \
  "$HOME/.local/bin/py7zr" \
  "$HOME/.local/bin/src"
# Giữ lại: aqt (Qt), git-filter-repo, cursor-agent, iii

echo ">>> [7/7] Done!"
echo ""
echo "Từ giờ dùng: cd ~/dev-nix-env && nix develop"
echo "Thêm alias vào ~/.bashrc nếu muốn auto-enter khi mở terminal."
