# Personal development environment

A reproducible, terminal-first development environment for backend work. Nix
provides the CLI and language toolchains; Home Manager owns user configuration;
nix-darwin and NixOS modules handle settings that genuinely belong to an
operating system.

The daily workflow is intentionally small: tmux, Neovim, lazygit, shells, test
runners, containers, and Kubernetes tools. The Neovim setup supplies a Go LSP,
Treesitter, Telescope, completion, and formatting without trying to hide Vim
behind a large IDE distribution.

## Supported systems

| Platform | Architectures | Configuration |
| --- | --- | --- |
| Ubuntu and other Linux | x86_64, AArch64 | Standalone Home Manager |
| macOS | Apple Silicon, Intel | nix-darwin + Home Manager, or standalone Home Manager |
| NixOS | x86_64 (inventory default) | NixOS module + integrated Home Manager |

Change the username and per-host architecture in `hosts/default.nix` before the
first activation. The default username is `toan`. No Git name/email or secrets
are stored in this repository.

## Repository layout

```text
.
├── flake.nix                 # inputs and output composition only
├── hosts/
│   ├── default.nix           # username and host architectures
│   ├── macos/                # nix-darwin host settings
│   ├── ubuntu/               # standalone Linux host boundary
│   └── nixos/                # NixOS host and generated hardware config
├── lib/                      # small output constructors
├── modules/
│   ├── common/               # shared Home Manager configuration
│   ├── darwin/               # macOS user settings
│   ├── linux/                # generic Linux user settings
│   └── nixos/                # NixOS system and user settings
├── packages/                 # base, build, Go, Rust, Node, and DevOps groups
└── dotfiles/                 # Neovim, tmux, and shell source configuration
```

Package lists live in exactly one place. Both `nix develop` and Home Manager
consume `packages/default.nix`; platform filters in the DevOps group keep Podman
on Linux and the Docker client on macOS.

## New machine bootstrap

1. Install Nix with flakes enabled. A multi-user installation is recommended.
2. Clone this repository.
3. Edit `hosts/default.nix` for the local username and architecture.
4. Follow the platform section below.

The original workflows remain available:

```bash
nix develop                 # temporary shell with the complete tool set
nix profile install .       # tools only; does not manage dotfiles
direnv allow                # automatic nix develop in this repository
```

Individual groups can also be installed, for example
`nix profile install .#go .#base`.

## Neovim Go development

Apply the Home Manager configuration once to install the tools and Neovim
configuration (choose the host that matches this machine):

```bash
nix run .#home-manager -- switch --flake .#ubuntu  # or .#macos
```

NixOS and full macOS installations should instead use the rebuild command from
their platform section below. To update, run `nix flake update`, review
`flake.lock`, run `nix flake check`, and apply the same Home Manager or rebuild
command again.

Start work from any Go repository:

```bash
cd /path/to/go-project
nvim .
```

Opening a directory shows Neo-tree. Move with `j`/`k`, press Enter to open the
selected file, and press `<Space>e` whenever you want to close or reopen the
tree. Telescope's file and text pickers use the Nix-provided `fd` and `ripgrep`.
Press `<Space>` and pause briefly to let which-key show the available shortcuts;
`<Space>?` shows the complete keybinding window.

The ten most useful bindings to learn first are:

| Key | Action |
| --- | --- |
| `<Space>e` | Toggle the file explorer |
| `<Space>ff` | Find files |
| `<Space>fg` | Grep text across the repository |
| `gd` | Go to a symbol's definition |
| `gr` | Find references to a symbol |
| `K` | Show hover documentation |
| `<Space>rn` | Rename a symbol |
| `<Space>f` | Format and organize imports |
| `<Space>db` | Toggle a debugger breakpoint |
| `<Space>dt` | Debug the nearest Go test |

`gD` goes to a declaration, `gi` goes to an implementation, `<Space>ca`
opens code actions, `<Space>xx` lists diagnostics, and `<Space>dc` starts or
continues the debugger. Go files are also formatted on save with `goimports`
followed by `gofumpt`; gopls and golangci-lint provide diagnostics. To run the
whole test suite without debugging, use `:terminal go test ./...`. To debug a
test, put the cursor inside it and press `<Space>dt`; use `<Space>dc` to continue
and `<Space>dq` to stop.

## Ubuntu

Install only the OS-owned prerequisites through APT:

```bash
sudo apt update
sudo apt install curl git xz-utils zsh
```

After installing Nix and cloning the repository, activate the user environment:

```bash
nix run .#home-manager -- switch --flake .#ubuntu
chsh -s /usr/bin/zsh
```

Nix manages user-space tools and dotfiles. Ubuntu should continue to manage the
kernel, networking, firewall, system Docker daemon (if used), and system login
shell. The included Linux `docker` and `docker-compose` commands intentionally
wrap rootless Podman to preserve the repository's previous behavior. Rootless
containers may also require Ubuntu's `uidmap`, `/etc/subuid`, and `/etc/subgid`
setup; these are OS concerns and are not modified here.

## macOS

For a full Apple Silicon installation (system settings plus Home Manager):

```bash
nix run .#darwin-rebuild -- switch --flake .#macos
darwin-rebuild switch --flake .#macos
```

Use `.#macos-intel` for an Intel Mac. The first command bootstraps
`darwin-rebuild`; later activations use the second command. Homebrew is not
required by this configuration. Install Docker Desktop, Colima, or another
daemon separately only if container workloads need one—the Nix package supplies
the client, not a macOS virtualization service.

On Apple Silicon, the user environment can instead be managed without adopting
nix-darwin:

```bash
nix run .#home-manager -- switch --flake .#macos
```

The pinned Home Manager release no longer publishes its CLI package for Intel
macOS, so `.#macos-intel` should be applied through nix-darwin. Nixpkgs 26.05 is
its final x86_64-darwin release, so Intel outputs use the separate
`nixpkgs-darwin-intel` input while maintained platforms track unstable. Intel
support is best-effort and should be retired when that pin is no longer safe.

## NixOS

The repository includes a real NixOS system boundary, not generic Linux settings
masquerading as a NixOS host. Before the first activation, replace the empty
hardware placeholder with the current machine's generated configuration:

```bash
nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
sudo nixos-rebuild switch --flake .#nixos
```

Review the generated file and configure the real boot loader, disk layout,
hostname, username, and networking before switching. The checked-in
`REPLACE_ME`/`nodev` values exist only to make cross-platform flake evaluation
possible and are not a deployable hardware configuration. The shared user
module is integrated through Home Manager. The system module enables
NetworkManager, Zsh, and Podman with Docker compatibility.

## Everyday maintenance

Apply user-only changes on Ubuntu or standalone macOS:

```bash
nix run .#home-manager -- switch --flake .#ubuntu  # or .#macos
```

Update pinned dependencies, format Nix files, and validate outputs:

```bash
nix flake update
nix fmt
nix flake check
nix flake check --all-systems --no-build
```

Review `flake.lock` before committing an update. `nix flake check` on one machine
builds checks only for that machine's system; `--all-systems --no-build` catches
cross-platform evaluation problems without attempting foreign builds.

## Extending the environment

### Add a package

Add it to the smallest matching file under `packages/`. Create a new group only
when it has a clear, durable responsibility. The group automatically becomes
part of the default bundle, development shell, and Home Manager environment.

### Add a module

Put shared user behavior under `modules/common/`, OS-specific user behavior under
`modules/linux/` or `modules/darwin/`, and NixOS system behavior under
`modules/nixos/`. Import a focused common module from
`modules/common/default.nix`.

### Add a host

Add its system to `hosts/default.nix`, create a small directory under `hosts/`,
and compose it in the appropriate `homeConfigurations`,
`darwinConfigurations`, or `nixosConfigurations` output in `flake.nix`. Keep
hardware details in the host directory and reusable behavior in `modules/`.

## Useful defaults

- tmux keeps `C-b`; use `C-b h/j/k/l` to move and uppercase letters to resize.
- Neovim uses Space as leader: `ff` files, `fg` text, `fb` buffers, and `f` format.
- LSP uses standard motion-friendly bindings: `gd`, `gr`, `K`, `<leader>rn`, and
  `<leader>ca`.
- Shell aliases are limited to `ll`, `la`, `cat` (bat), and `lg` (lazygit).

## Troubleshooting

- If Home Manager refuses to replace an existing dotfile, move that file aside
  once, rerun activation, and compare it with the generated version.
- If an unfree-package error appears, use the flake outputs rather than importing
  these package files independently; the flake enables unfree packages.
- If `nix develop` does not activate through direnv, run `direnv allow` again
  after changing `.envrc` or `flake.lock`.
- If Podman fails on Ubuntu, verify subordinate UID/GID mappings and the distro's
  rootless-container prerequisites.
- Use `nix flake show` to list the exact outputs available on the current revision.
