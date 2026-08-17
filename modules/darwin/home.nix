{ lib, username, ... }:

{
  imports = [ ../common ];

  home.homeDirectory = lib.mkDefault "/Users/${username}";
}
