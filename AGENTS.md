# AGENTS.md

Instructions for coding agents working in this repo: dastbe's nix-darwin +
home-manager configuration.

## Layout

A system is a machine combined with a user, wired together in `flake.nix`
via `lib/mksystem.nix`:

| Path                            | What lives there                          |
| ------------------------------- | ----------------------------------------- |
| `flake.nix`, `flake.lock`       | inputs, outputs, formatter                |
| `lib/`                          | helpers for building systems              |
| `machines/<name>.nix`           | per-machine settings                      |
| `users/<user>/darwin.nix`       | per-user nix-darwin config (homebrew, fonts) |
| `users/<user>/home-manager.nix` | per-user home-manager config (packages, programs) |
| `users/<user>/agent-conventions.md` | user-level agent rules, installed as `~/.claude/CLAUDE.md` |

## Building and verifying

- Build without activating:
  `nix build '.#darwinConfigurations.personal-macbook-air-m1.system' --no-link`
- Check the flake: `nix flake check`
- Format: `nix fmt`
- Activating (`make switch NIXNAME=personal-macbook-air-m1`) changes the
  running system and needs sudo. Leave that to the user unless asked.

## Conventions

The general working rules (always jj, `area: description` commits, Linear
for tracking) live in `users/dastbe/agent-conventions.md`, which switch
installs as `~/.claude/CLAUDE.md`. Edit them there. This file only adds what
is specific to this repo.

## Publishing

Every commit must build on its own. To publish a stack:
`jj bookmark set main -r <rev>` then `jj git push -b main`.

## Commit areas

| Area             | Path                                          |
| ---------------- | --------------------------------------------- |
| `flake`          | `flake.nix`, `flake.lock`                     |
| `lib/mksystem`   | `lib/mksystem.nix`                            |
| `<machine-name>` | `machines/<machine-name>.nix`                 |
| `darwin`         | `users/<user>/darwin.nix`                     |
| `home-manager`   | `users/<user>/home-manager.nix`               |
| `claude-code`    | `programs.claude-code`, `users/<user>/agent-conventions.md` |
| `agents`         | `AGENTS.md`                                   |

Areas also shape how the repo is organized. If a change doesn't fit an
existing area, or an area keeps collecting unrelated changes, split the file
so the new piece gets its own path and area (for example
`users/<user>/home/helix.nix` → `helix`), then add it to the table above.
