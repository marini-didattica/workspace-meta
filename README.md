# workspace-meta

Glue repo for a multi-repo slide/material workspace. It holds no content — it
keeps the shell and OpenCode setup shared across the sibling repositories and
provides coordination scripts.

## Contents

- `activate.fish` — activates the workspace in fish: exports `OPENCODE_CONFIG`
  and `OPENCODE_CONFIG_DIR` and prepends `bin/` to `PATH` (`deactivate` undoes it).
- `opencode.jsonc` — shared OpenCode config: loads `AGENTS.md`, enables LSP and
  the `code-graph`, `chrome-devtools` and `context7` MCP servers.
- `bin/wm` — command to work across the sibling repositories (see below).
- `bin/run-all` — placeholder.
- `AGENTS.md` — the workspace map and working rules for agents.

## Usage

```fish
source ~/workspace-meta/activate.fish
```

> **OpenCode v2 note.** Because the workspace relies on `OPENCODE_CONFIG`, the
> background server does not pick up this configuration. Disable it so sessions
> use the activated config:
>
> ```sh
> opencode service set disabled true
> ```

## wm

`wm` operates on the git repositories found next to `workspace-meta` and uses
[gum](https://github.com/charmbracelet/gum) pickers to choose them.

```sh
wm git clone     # pick repos from the GitHub org, confirm, clone them here
wm git status    # run `git status` in the repositories you select
wm foreach       # run a command in the repositories you select
wm deps bump-slidev  # update the in-house slidev theme/addons git deps
wm deps bump-typst   # update the typst theme/components submodules, commit and push
wm exam watch-corrections [correzioni-dir] [--out out-dir]
                     # generate and watch JSON correction PDFs
```

- `git clone` lists the repositories of the `marini-didattica` organization
  (override with `WM_ORG`) and selects all of them except `workspace-meta`.
- `git status` and `foreach` list the repositories already cloned around
  `workspace-meta`; all of them are selected by default.
- `exam watch-corrections` reads the correction descriptors from
  `correzioni-dir` (defaults to `./correzioni`, or the current directory if it
  does not exist). It writes generated stubs to `<out>/typ` and watched PDFs to
  `<out>/pdf`; `--out` defaults to `/tmp/marini-didattica/exams`.

## Dependencies

| Tool | Needed by | Notes |
| ---- | --------- | ----- |
| [`gum`](https://github.com/charmbracelet/gum) | interactive `wm` commands | pickers, prompts and highlighting |
| [`gh`](https://cli.github.com) | `wm git clone` | must be authenticated (`gh auth login`) |
| [`typst`](https://typst.app) | `wm exam watch-corrections` | compiles and watches the generated stubs |
| [`fish`](https://fishshell.com) | `activate.fish` | shell activation |
