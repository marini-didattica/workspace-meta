# workspace-meta

Glue repo for a multi-repo slide/material workspace. It holds no content — it
keeps the shell and OpenCode setup shared across the sibling repositories and
provides coordination scripts.

## Contents

- `activate.fish` — activates the workspace in fish: exports `OPENCODE_CONFIG`
  and `OPENCODE_CONFIG_DIR` and prepends `bin/` to `PATH` (`deactivate` undoes it).
- `opencode.jsonc` — shared OpenCode config: loads `AGENTS.md`, defines the
  `checker` agent, enables LSP and the `code-graph`, `chrome-devtools` and
  `context7` MCP servers.
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
wm exam generate-solutions [exam-dir] --out <folder>
                     # generate one solution folder per exam set
wm exam deploy <exam-dir> [--force]
                     # deploy corrections and answers to student private folders
wm students collect -f <name> --src <dir> [--dest <dir>] [--move]
                     # collect one file/folder from every student
wm students delete -f <name> --src <dir>
                     # delete one file/folder from every student
```

- `git clone` lists the repositories of the `marini-didattica` organization
  (override with `WM_ORG`) and selects all of them except `workspace-meta`.
- `git status` and `foreach` list the repositories already cloned around
  `workspace-meta`; all of them are selected by default.
- `exam watch-corrections` reads the correction descriptors from
  `correzioni-dir` (defaults to `./correzioni`, or the current directory if it
  does not exist). It writes generated stubs to `<out>/typ` and watched PDFs to
  `<out>/pdf`; `--out` defaults to `/tmp/marini-didattica/exams`.
- `exam generate-solutions` reads the exam descriptor from
  `<exam-dir>/testo/*.json` (defaults to the current directory; a descriptor
  path may be passed instead) and the exercise solutions from
  `<exam-dir>/soluzione/<EX_ID>.<ext>`. For every set declared by the
  descriptor it writes `<out>/<set>/` and copies each exercise's solution there,
  renamed according to the descriptor's `answer-file` pattern (`{ordinal}`,
  `{id}`, `{category}`, `{tag}` and `{set}` are expanded). It fails without
  writing anything if a solution file is missing.
- `exam deploy` copies each correction JSON and its student answers into
  `content/raw/private/<class>/<student>/<exam>/`, generating
  `correzione.typ` and `le-tue-risposte/`. Existing files are left untouched
  unless `--force` is passed.
- `students collect` looks for `<student>/<name>` under `--src` and copies (or
  moves with `--move`) each match to `<dest>/<name>/<student>`. `--dest`
  defaults to `/tmp/marini-didattica/collected`. Relative `--src` paths first
  resolve from the current directory, then from `materiale/content/raw`, then
  from the workspace root.
- `students delete` removes every `<student>/<name>` under `--src`. Both
  student commands print the full list and ask for confirmation before making
  changes, then report successful matches out of the total student folders.

## Dependencies

| Tool | Needed by | Notes |
| ---- | --------- | ----- |
| [`gum`](https://github.com/charmbracelet/gum) | interactive `wm` commands | pickers, prompts and highlighting |
| [`gh`](https://cli.github.com) | `wm git clone` | must be authenticated (`gh auth login`) |
| [`typst`](https://typst.app) | `wm exam watch-corrections` | compiles and watches the generated stubs |
| [`jq`](https://jqlang.github.io/jq/) | `wm exam deploy`, `wm exam generate-solutions` | reads descriptors and student keys |
| [`fish`](https://fishshell.com) | `activate.fish` | shell activation |
