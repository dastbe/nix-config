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
- Format: `nix fmt` (formats every `.nix` file in the repo)
- Activating (`make switch NIXNAME=personal-macbook-air-m1`) changes the
  running system and needs sudo. Only switch when the user asks.
- In a Rex terminal (`REX_BLOCK` is set), run the switch in a new pane
  beside yours, so the user can approve sudo with Touch ID or decline:

  ```sh
  rex split -s "$REX_SESSION" -b "$REX_BLOCK" --label "make switch" \
    --wait -c ~/.nix-cfg -- zsh -c 'make switch NIXNAME=personal-macbook-air-m1 && exit
      s=$?; print -P "\n%F{red}make switch failed ($s)%f, press return to close"; read; exit $s'
  ```

  Run it in the background. The pane closes itself when the switch
  succeeds. If it fails, the pane stays open until the user presses
  return, so they can read the error. `--wait` returns the exit status
  once the pane closes. Don't edit the checkout while it runs:
  `darwin-rebuild` evaluates it again after sudo. Outside Rex, ask the
  user to run the switch.

## Conventions

The general working rules (always jj, `area: description` commits, Linear
for tracking) live in `users/dastbe/agent-conventions.md`, which switch
installs as `~/.claude/CLAUDE.md`. Edit them there. This file only adds what
is specific to this repo.

## Workspaces: work in this checkout

This overrides the per-issue workspace rule in the user-level conventions.
Make nix-cfg changes directly in `~/.nix-cfg`, not in a workspace under
`~/workplace/claude`: `make switch` builds from this checkout, so changes
made elsewhere aren't what gets activated.

The working copy may still hold the user's in-progress change, so check
`jj diff` and `jj log` first and start your own change with `jj new`.

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
| `neovim`         | `users/<user>/home/neovim/`                   |

Areas also shape how the repo is organized. If a change doesn't fit an
existing area, or an area keeps collecting unrelated changes, split the file
so the new piece gets its own path and area (for example
`users/<user>/home/helix.nix` → `helix`), then add it to the table above.
