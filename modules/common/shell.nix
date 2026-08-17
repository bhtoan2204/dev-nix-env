{ lib, ... }:

let
  aliases = builtins.readFile ../../dotfiles/zsh/aliases.zsh;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = lib.mkAfter aliases;
    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      share = true;
      size = 50000;
      save = 50000;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    initExtra = aliases;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
