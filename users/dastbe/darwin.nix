{ pkgs, currentSystemUser, ... }:

{
  fonts.packages = with pkgs; [
    recursive
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  homebrew = {
    enable = true;

    # Make this list authoritative: casks removed here get uninstalled on the
    # next switch. ("zap" would also delete app data; "uninstall" keeps it.)
    onActivation.cleanup = "uninstall";

    casks = [
      "1password"
      "alacritty"
      "discord"
      "google-chrome"
      "slack"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${currentSystemUser}.home = "/Users/${currentSystemUser}";
}
