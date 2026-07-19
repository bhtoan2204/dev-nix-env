# Portable development environment

Reproducible Go, Rust, Python, Node.js, and DevOps tools for Linux, managed by
Nix flakes.

## Set up a new machine

After installing Nix with flakes enabled, clone this repository and run:

```bash
nix profile install .
```

This installs the default tool collection into the user profile. To use it only
inside this repository instead, run:

```bash
nix develop
```

For automatic activation, enable the `direnv` hook in your shell once, then run:

```bash
direnv allow
```

## Maintenance

Update pinned packages and verify every supported Linux architecture:

```bash
nix flake update
nix flake check --all-systems --no-build
```

The flake currently supports `x86_64-linux` and `aarch64-linux`.

## Structure

Package lists are grouped by responsibility:

```text
nix/packages/
├── system.nix  # CLI, build tools, Python, and native libraries
├── go.nix      # Go toolchain and utilities
├── rust.nix    # Rust toolchain and Cargo utilities
└── devops.nix  # Containers, Node.js, Stripe, and Docker wrappers
```
