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

## Workspaces: one per Linear issue

Do the work for each Linear issue (see Work tracking below) in its own jj
workspace under `~/workplace/claude/<workspace-name>`, not in the checkout
the session started in. That checkout is the user's, and its working copy
may hold their in-progress change.

- Name the workspace `<repo>-<issue-key>` in lowercase (e.g.
  `mono-das-123`). The repo prefix matters because the directory is shared
  across repos, and one issue can touch more than one repo.
- If a workspace for the issue already exists, continue in it rather than
  creating another. Check with `jj workspace list`.
- Otherwise, create it from the user's checkout of the repo with
  `jj workspace add ~/workplace/claude/<name> --name <name> --colocate -r <base>`,
  where `<base>` is `trunk()` for new work (run `jj git fetch` first so
  it's current) or the tip of the stack you're extending. Then read, edit,
  build, and run jj from inside it.
- Workspaces must be colocated with Git so git-aware tooling works in
  them; `--colocate` gives the workspace its own Git worktree. It needs the
  user's checkout to be colocated too. If it isn't, ask the user before
  running `jj git colocation enable` there.
- A workspace shares the repo store of the checkout it was created from,
  so commits are visible from both and the user sees your changes in
  `jj log` without any extra step. If you rewrite a commit their working
  copy sits on, tell them to run `jj workspace update-stale`.
- When the work has landed or been handed off, ask before cleaning up,
  then run `jj workspace forget <name>`, delete the directory, and run
  `git worktree prune` in the user's checkout to drop the stale Git
  worktree (the one mutating `git` command allowed here, since jj has no
  equivalent). Forgetting a workspace keeps its commits.

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
