{ inputs, ... }:

{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in {
  # Home-manager 22.11 requires this be set. We never set it so we have
  # to use the old state version.
  home.stateVersion = "18.09";

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = [
    pkgs.bat
    pkgs.eza
    pkgs.fd
    pkgs.git-branchless
    pkgs.gh
    pkgs.go
    pkgs.gopls
    pkgs.helix
    pkgs.htop
    pkgs.hyperfine
    pkgs.ripgrep
    pkgs.rustup
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
  ]);

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.alacritty = {
    enable = true;

    settings = {
      font.normal = { family = "FiraCode Nerd Font Mono"; style = "Regular"; };
      
      keyboard.bindings = [
        { key = "K"; mods = "Command"; action = "ClearHistory"; }
      ];

      import = [
        pkgs.alacritty-theme.catppuccin_frappe
      ];
    };
  };

  programs.fzf = {
    enable = true;

    defaultOptions = [
      "--preview 'bat --color=always {}'"
    ];
  };

  programs.git = {
    enable = true;

    userName = "David Bell";
    userEmail = "dastbe@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.neovim = {
    enable = true;

    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = [
      pkgs.vimPlugins.copilot-vim
      pkgs.vimPlugins.nvim-treesitter.withAllGrammars
      pkgs.vimPlugins.vim-fugitive
    ];
  };

  programs.starship = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;

    enableZshIntegration = true;    
  };

  programs.zsh = {
    enable = true;
    autocd = false;
    autosuggestion.enable = true;
    defaultKeymap = "viins";
    enableCompletion = true;

    shellAliases = {
      cat = "bat";
      cd = "z";
      ls = "eza --long --binary --group --git";
    };
  };
}
