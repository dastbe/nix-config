{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in {
  # This value pins home-manager's defaults to the release this config was
  # first written against. Read the home-manager release notes before bumping.
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

  programs.fzf = {
    enable = true;

    defaultOptions = [
      "--preview 'bat --color=always {}'"
    ];
  };

  # Installed via the homebrew cask (darwin.nix); home-manager only writes
  # the config.
  programs.ghostty = {
    enable = true;
    package = lib.mkIf isDarwin null;

    settings = {
      theme = "Catppuccin Frappe";
      font-family = "FiraCode Nerd Font Mono";
      # Shift+Enter inserts a newline in Claude Code (and other TUIs).
      keybind = [ "shift+enter=text:\\x1b\\r" ];
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user.name = "David Bell";
      user.email = "dastbe@gmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings.theme = "sonokai_andromeda";
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
