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
      "discord"
      "ghostty"
      "google-chrome"
      "slack"
      "zed"
    ];
  };

  # claude-code and the 1Password CLI are unfree.
  nixpkgs.config.allowUnfree = true;

  # Installs `op` at /usr/local/bin/op, the only path the 1Password app
  # integration trusts.
  programs._1password.enable = true;

  security.pam.services.sudo_local.touchIdAuth = true;

  users.users.${currentSystemUser}.home = "/Users/${currentSystemUser}";
}
