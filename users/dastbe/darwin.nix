{ inputs, pkgs, ... }:

{
  fonts = {
    packages = with pkgs; [
      recursive
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "JetBrainsMono"
        ];
      })
    ];
  };

  homebrew = {
    enable = true;
    casks  = [
      "1password"
      "alacritty"
    ];
  };

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  security.pam.enableSudoTouchIdAuth = true;

  users.users.dastbe= {
    home = "/Users/dastbe";
    # shell = pkgs.zsh;
  };
}
