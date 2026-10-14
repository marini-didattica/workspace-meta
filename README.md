# workspace-meta

Meta repository that wires a **multi-repo teaching workspace** together so that
human shells and agentic OpenCode sessions share the same environment and
configuration.

This repo stores **no slide or document content**. It only contains the glue:

- shell activation (`activate.fish`) that exports the OpenCode config paths and
  puts the helper scripts on `PATH`;
- the shared OpenCode configuration (`opencode.jsonc`) and instructions
  (`AGENTS.md`);
- small coordination scripts in `bin/`.

Every sibling directory is its **own git repository**, deployed independently.

## Workspace layout

The workspace is meant to be checked out as a flat directory of sibling repos:

| Directory       | Repository (GitHub)                              | Contents                                        |
| --------------- | ------------------------------------------------ | ----------------------------------------------- |
| `prime`         | [`russell-informatica/prime`]                     | Slidev decks (Prime class)                      |
| `seconde`       | [`russell-informatica/seconde`]                   | Slidev decks (Seconde class)                    |
| `extra-slides`  | [`russell-informatica/extra-slides`]              | Extra Slidev decks                              |
| `misc`          | [`russell-informatica/misc`]                      | Misc material, mostly Typst documents           |
| `slidev-theme`  | [`russell-informatica/slidev-theme`]              | Shared Slidev theme (`slidev-theme-russell`)    |
| `slidev-addons` | [`russell-informatica/slidev-addons`]             | Shared Slidev components (`slidev-addons-russell`) |
| `slide-site`    | [`russell-informatica/slide-site`]                | Astro dashboard that links the published material |
| `workspace-meta`| [`russell-informatica/workspace-meta`]            | **This repo** — coordination and configuration  |

[`russell-informatica/prime`]: https://github.com/russell-informatica/prime
[`russell-informatica/seconde`]: https://github.com/russell-informatica/seconde
[`russell-informatica/extra-slides`]: https://github.com/russell-informatica/extra-slides
[`russell-informatica/misc`]: https://github.com/russell-informatica/misc
[`russell-informatica/slidev-theme`]: https://github.com/russell-informatica/slidev-theme
[`russell-informatica/slidev-addons`]: https://github.com/russell-informatica/slidev-addons
[`russell-informatica/slide-site`]: https://github.com/russell-informatica/slide-site
[`russell-informatica/workspace-meta`]: https://github.com/russell-informatica/workspace-meta

> The deck/`misc` repos each ship a GitHub Actions workflow that builds their
> artifact and publishes it to GitHub Pages. The `slide-site` dashboard links to
> those published artifacts.

## Quick start

The activation script is written for [fish](https://fishshell.com/):

```fish
source ~/workspace-meta/activate.fish
```

After activation the prompt prints `Activated workspace-meta: <path>` and the
following are set:

| Variable             | Value                        | Purpose                                   |
| -------------------- | ---------------------------- | ----------------------------------------- |
| `WORKSPACE_META`     | Absolute path to this repo   | Stable anchor for scripts                 |
| `OPENCODE_CONFIG`    | `$WORKSPACE_META/opencode.jsonc` | workspace OpenCode configuration       |
| `OPENCODE_CONFIG_DIR`| `$WORKSPACE_META/opencode`   | workspace OpenCode state directory        |
| `PATH`               | `$WORKSPACE_META/bin` prepended | Makes helper scripts available          |

Run `deactivate` to undo all of the above in the current shell.

> **OpenCode v2 (server/client) warning.** OpenCode v2 runs a background
> server/client pair. Because this workspace relies on the `OPENCODE_CONFIG`
> environment variable, the workspace configuration is **not** picked up
> correctly by the background server. Disable the service so each session reads
> the activated config:
>
> ```sh
> opencode service set disabled true
> ```

## OpenCode configuration

`opencode.jsonc` is loaded for every session started from an activated shell. It:

- loads `AGENTS.md` as project instructions (`"instructions": ["./AGENTS.md"]`);
- enables LSP;
- registers three local MCP servers:
  - **code-graph** — index and navigate the codebase;
  - **chrome-devtools** — drive a headless Chromium instance (used to inspect
    the running decks, e.g. console output);
  - **context7** — fetch up-to-date library documentation.

The `slidev` MCP server (usually served by a running deck at
`http://localhost:3030/__mcp`) is present but commented out; enable it per
session when a deck is running.

## Scripts

Everything in `bin/` is prepended to `PATH` by `activate.fish`.

| Script    | Status      | Description                                          |
| --------- | ----------- | ---------------------------------------------------- |
| `run-all` | placeholder | Reserved for running a command across every repo.    |

## Working on the decks

A single deck is served with Slidev:

```sh
cd prime            # or seconde / extra-slides
bun run dev src/<deck>/0-main.md -p <port>
```

Reserve user ports **from 3130 upward**, and use a different port per deck when
several servers run in parallel. The Slidev MCP integrates on port `3030`; the
Astro dashboard (`slide-site`) uses its default `4321`.

The decks consume the shared theme and addon as git dependencies
(`slidev-theme-russell`, `slidev-addons-russell`). Visual changes belong in
`slidev-theme`, reusable components in `slidev-addons`, so a change benefits
every deck at once.

## Conventions

- **Commits:** conventional commits — `feat|chore|fix|docs|refactor|test:
  message`. Keep them concise and omit the scope unless it is necessary.
- **Repo scope:** commit each change in the repository it belongs to. A shared
  visual change is a commit in `slidev-theme`, not in the deck that consumes it.
- **Dependencies:** do not bump the deck dependencies; only refresh the
  `slidev-theme-russell` / `slidev-addons-russell` git dependencies after those
  repos change.

## Security note

`opencode/service.json` holds the local OpenCode service password and is
currently **tracked in git**. It should be gitignored and rotated, since the
value is already part of the repository history.
