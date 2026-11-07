{ pkgs, ... }:

{
  # Everything neovim loads comes from nixpkgs: plugins are on the runtime
  # path at build time, so there's no plugin manager and nothing to fetch on
  # first start. Helix stays the default editor.
  programs.neovim = {
    enable = true;

    # Opt out of the providers the 18.09 stateVersion would turn on; nothing
    # here needs them.
    withPython3 = false;
    withRuby = false;

    plugins = with pkgs.vimPlugins; [
      blink-cmp
      catppuccin-nvim
      conform-nvim
      fidget-nvim
      gitsigns-nvim
      lualine-nvim
      mini-nvim
      nvim-lspconfig
      nvim-treesitter.withAllGrammars
      nvim-web-devicons
      oil-nvim
      plenary-nvim
      telescope-fzf-native-nvim
      telescope-nvim
      which-key-nvim
    ];

    # Only on neovim's PATH. gopls, nil, gofmt, rust-analyzer and rustfmt
    # already come from home.packages and rustup, so they aren't repeated.
    extraPackages = [
      pkgs.lua-language-server
      pkgs.nixfmt
      pkgs.stylua
    ];

    initLua = builtins.readFile ./init.lua;
  };
}
