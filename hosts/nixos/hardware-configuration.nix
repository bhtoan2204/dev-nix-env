# Evaluation-only placeholder. Replace this entire file with output from
# `nixos-generate-config --show-hardware-config`, then configure the machine's
# real boot loader, before the first `nixos-rebuild switch`.
{ ... }:

{
  fileSystems."/" = {
    device = "/dev/disk/by-label/REPLACE_ME";
    fsType = "ext4";
  };

  # `nodev` prevents this placeholder from naming or writing a physical disk.
  boot.loader.grub.devices = [ "nodev" ];
}
