# Builds a system by combining a machine (machines/<name>.nix) with a user
# (users/<user>/{darwin,nixos}.nix + users/<user>/home-manager.nix).
{
  nixpkgs,
  overlays,
  inputs,
}:

name:
{
  system,
  user,
  darwin ? false,
}:

let
  # The config files for this system.
  machineConfig = ../machines/${name}.nix;
  userOSConfig = ../users/${user}/${if darwin then "darwin" else "nixos"}.nix;
  userHMConfig = ../users/${user}/home-manager.nix;

  # NixOS vs nix-darwin functions
  systemFunc = if darwin then inputs.darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  home-manager =
    if darwin then inputs.home-manager.darwinModules else inputs.home-manager.nixosModules;

  # Extra arguments available to every module (system and home-manager) so
  # they can parameterize on the machine/user they are being combined into.
  specialArgs = {
    inherit inputs;
    currentSystem = system;
    currentSystemName = name;
    currentSystemUser = user;
  };
in
systemFunc {
  inherit system specialArgs;

  modules = [
    { nixpkgs.overlays = overlays; }

    machineConfig
    userOSConfig
    home-manager.home-manager
    {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      # Move pre-existing unmanaged dotfiles aside instead of failing activation.
      home-manager.backupFileExtension = "hm-backup";
      home-manager.extraSpecialArgs = specialArgs;
      home-manager.users.${user} = import userHMConfig;
    }
  ];
}
