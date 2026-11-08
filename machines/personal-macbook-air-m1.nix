{ pkgs, currentSystemUser, ... }: {
  # Nix itself is installed and managed by Determinate Nix, so nix-darwin must
  # not manage the daemon or /etc/nix/nix.conf. Nix settings belong in
  # /etc/nix/nix.custom.conf (flakes are already enabled by Determinate).
  nix.enable = false;

  # Options that apply to a user (homebrew, defaults, etc.) need to know who
  # the primary user of this machine is.
  system.primaryUser = currentSystemUser;

  # Read the nix-darwin changelog before changing this.
  system.stateVersion = 4;

  # zsh is the default shell on Mac and we want to make sure that we're
  # configuring the rc correctly with nix-darwin paths.
  programs.zsh.enable = true;
  programs.zsh.shellInit = ''
    # Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
      . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    # End Nix
  '';

  environment.shells = with pkgs; [
    bashInteractive
    zsh
  ];
}
