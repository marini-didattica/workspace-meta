# workspace-meta

Glue repo for a multi-repo slide/material workspace. It holds no content — it
keeps the shell and OpenCode setup shared across the sibling repositories and
provides a few coordination scripts.

## Contents

- `activate.fish` — activates the workspace in fish: exports `OPENCODE_CONFIG`
  and `OPENCODE_CONFIG_DIR` and prepends `bin/` to `PATH` (`deactivate` undoes it).
- `opencode.jsonc` — shared OpenCode config: loads `AGENTS.md`, enables LSP and
  the `code-graph`, `chrome-devtools` and `context7` MCP servers.
- `bin/` — helper scripts (`run-all` is a placeholder for now).
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
