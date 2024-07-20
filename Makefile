# The name of the nixosConfiguration in the flake
NIXNAME ?= unset

# We need to do some OS switching below.
UNAME := $(shell uname)

switch:
ifeq ($(UNAME), Darwin)
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes ".#darwinConfigurations.${NIXNAME}.system"
	./result/sw/bin/darwin-rebuild switch --flake "$$(pwd)#${NIXNAME}"
else
	sudo NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 nixos-rebuild switch --flake ".#${NIXNAME}"
endif

# This builds the given NixOS configuration and pushes the results to the
# cache. This does not alter the current running system. This requires
# cachix authentication to be configured out of band.
cache:
	nix build --extra-experimental-features nix-command --extra-experimental-features flakes '.#darwinConfigurations.$(NIXNAME).system' --json \
	| jq -r '.[].outputs | to_entries[].value' \
	| cachix push dastbe
