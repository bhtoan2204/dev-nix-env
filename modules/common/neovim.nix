{ pkgs, ... }:

let
  plugins = pkgs.vimPlugins;
  treesitter = plugins.nvim-treesitter.withPlugins (
    parsers: with parsers; [
      bash
      go
      gomod
      gosum
      gotmpl
      json
      lua
      markdown
      markdown_inline
      nix
      python
      rust
      toml
      yaml
    ]
  );
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = false;
    withRuby = false;

    # lazy.nvim loads the remaining plugins directly from immutable Nix store
    # paths listed below. It never clones or updates them itself.
    plugins = [ plugins.lazy-nvim ];

    initLua = ''
      vim.opt.rtp:prepend("${plugins.lazy-nvim}")

      local nix_plugins = {
        { name = "plenary.nvim", dir = "${plugins.plenary-nvim}" },
        { name = "nui.nvim", dir = "${plugins.nui-nvim}" },
        { name = "nvim-web-devicons", dir = "${plugins.nvim-web-devicons}" },
        { name = "nvim-lspconfig", dir = "${plugins.nvim-lspconfig}" },
        { name = "blink.cmp", dir = "${plugins.blink-cmp}" },
        { name = "nvim-treesitter", dir = "${treesitter}" },
        {
          name = "telescope.nvim",
          dir = "${plugins.telescope-nvim}",
          dependencies = { "plenary.nvim" },
        },
        { name = "conform.nvim", dir = "${plugins.conform-nvim}" },
        { name = "nvim-dap", dir = "${plugins.nvim-dap}" },
        {
          name = "nvim-dap-go",
          dir = "${plugins.nvim-dap-go}",
          dependencies = { "nvim-dap" },
        },
        { name = "gitsigns.nvim", dir = "${plugins.gitsigns-nvim}" },
        {
          name = "neo-tree.nvim",
          dir = "${plugins.neo-tree-nvim}",
          dependencies = { "plenary.nvim", "nui.nvim", "nvim-web-devicons" },
        },
        { name = "which-key.nvim", dir = "${plugins.which-key-nvim}" },
        { name = "nvim-lint", dir = "${plugins.nvim-lint}" },
      }

      ${builtins.readFile ../../dotfiles/nvim/init.lua}
    '';
  };
}
