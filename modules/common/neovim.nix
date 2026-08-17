{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = false;
    withRuby = false;

    plugins = with pkgs.vimPlugins; [
      (nvim-treesitter.withPlugins (
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
      ))
      nvim-lspconfig
      plenary-nvim
      telescope-nvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      conform-nvim
    ];

    initLua = builtins.readFile ../../dotfiles/nvim/init.lua;
  };
}
