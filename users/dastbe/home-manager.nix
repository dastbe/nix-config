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
    pkgs.git-branchless
    pkgs.gopls
    pkgs.helix
    pkgs.htop
    pkgs.hyperfine
    pkgs.ripgrep
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
  ]);

  home.sessionVariables = {
    NIXNAME = "macbook-air-m1";
  };

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

    enableZshIntegration = true;    
  };

  programs.git = {
    enable = true;

    userName = "David Bell";
    userEmail = "dastbe@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
    };
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
