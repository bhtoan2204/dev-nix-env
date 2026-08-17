{ lib, username, ... }:

{
  imports = [ ../common ];
  home.homeDirectory = lib.mkDefault "/home/${username}";
}
