{
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 10;
    historyLimit = 100000;
    mouse = true;
    terminal = "tmux-256color";
    extraConfig = builtins.readFile ../../dotfiles/tmux/tmux.conf;
  };
}
