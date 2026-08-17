{
  programs.git = {
    enable = true;
    settings = {
      alias = {
        co = "checkout";
        st = "status --short --branch";
        last = "log -1 --stat";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      fetch.prune = true;
      rerere.enabled = true;
    };
  };
}
