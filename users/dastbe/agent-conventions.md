# Working conventions

These apply in every repo. A repo's own AGENTS.md or CLAUDE.md can add to
them or override them.

## Version control: always jj

Use `jj` for every repo action. In colocated repos, don't use mutating `git`
commands (commit, rebase, reset, checkout, push); read-only `git` is fine
when jj has no equivalent.

- Keep work as a stack of small, single-purpose changes, each of which
  builds and passes checks on its own.
- Start a change with `jj new` (or `jj new -A/-B <rev>` to insert it into a
  stack) and name it with `jj describe`.
- Before describing or squashing into `@`, check `jj diff` and `jj log`:
  the working copy may already hold someone else's in-progress change, so
  start a new change instead of relabelling theirs.
- Revise earlier changes with `jj edit <rev>` or `jj squash --into <rev>`
  rather than piling fixups on top.
- Push with `jj git push`. Ask before rewriting commits that are already on
  a remote, since that needs a force push.

## Commit messages: `area: description`

The first line is `area: description`.

- `area` names the part of the repo the change touches, usually derived
  from its path (a directory, a file, or a component). Follow the areas a
  repo already uses; its AGENTS.md may list them.
- `description` is lowercase and imperative, e.g. `parser: handle empty
  input`.
- The body explains why, wrapped at ~72 columns.
- If a change spans areas, split it, or use the area that drives it.

Areas also shape how a repo is organized. If a change doesn't fit an
existing area, or an area keeps collecting unrelated changes, that's a sign
the code should move to its own path (and get its own area).

## Work tracking: Linear

Track work in Linear, team **Dastbe** (key `DAS`).

- Before starting non-trivial work, find or create the issue for it.
- Reference the issue in the commit body, e.g. `Refs: DAS-123`.
- Update the issue's status as work lands, and link the pushed commits.
