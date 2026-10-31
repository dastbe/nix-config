{ pkgs, currentSystemUser, ... }:

{
  fonts.packages = with pkgs; [
    recursive
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  homebrew = {
    enable = true;
    casks  = [
      "1password"
      "alacritty"
      "arc"
      "discord"
      "google-chrome"
      "slack"
    ];
  };

  nixpkgs = {
    config = {
      allowBroken = true;
      allowUnfree = true;
      allowUnsupportedSystem = true;
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${currentSystemUser}.home = "/Users/${currentSystemUser}";
}
