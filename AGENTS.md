# Workspace
This is a multi-repo workspace for school material. The repositories live side by side, each with its own git history and its own GitHub Pages deployment:
.
├── prime: slidev slide decks (Prime class)
├── seconde: slidev slide decks (Seconde class)
├── extra-slides: extra slidev slide decks
├── misc: misc materials, mainly typst documents
├── slidev-theme: slidev theme (slidev-theme-russell) used by every deck
├── slidev-addons: slidev addons (slidev-addons-russell) used by every deck
├── slide-site: astro dashboard linking the published slides and material
└── workspace-meta: scripts and configuration coordinating the multi-repo agentic workflow

Deck repos consume slidev-theme and slidev-addons as npm git dependencies. prime, seconde, extra-slides and misc ship GitHub Actions workflows that build their artifact and deploy it to GitHub Pages; slide-site links to the published artifacts.

Source `workspace-meta/activate.fish` once per shell: it exports `OPENCODE_CONFIG` / `OPENCODE_CONFIG_DIR` and prepends `bin/` to `PATH`.

# Workflows
The vast majority of work is slide creation. Prefer changes that target the ecosystem as a whole: a visual change belongs in slidev-theme, a reusable component in slidev-addons.

Each deck is served with Slidev from its repo root:
`cd <repo> && bun run dev src/<deck>/0-main.md -p <port>`
User ports start at 3130; use a distinct port per deck when running several servers in parallel. A running deck exposes its Slidev MCP on 3030, the Astro dashboard uses 4321.

Entry points are the `0-main.md` files under `src/`. The Pages build maps each one to `/<repo>/<deck>/` (hash router), so verify with `bun run build` before committing.

# Don't
- Don't bump third-party dependencies (`@slidev/cli`, `vue`, ...). After changing slidev-theme or slidev-addons, only refresh those two git dependencies.
- Don't add heavy HTML/Vue to slides; stay markdown-first and ask before creating a new component.
- Don't edit generated output (`dist/`, `node_modules/`) or `bun.lock` by hand.

# Repos & VCS
Every subdirectory is its own git repository: a change to the theme is a commit in slidev-theme, not in the deck that consumes it. Commit in the repository that owns the change; pushing to main triggers that repo's Pages deployment.
Use conventional commit messages: `feat|chore|fix|docs|refactor|test: message`. Keep them concise and omit the scope unless it is strictly necessary.

# Per-repo instructions
Each repository may carry its own AGENTS.md with repo-specific rules (theme internals, tooling restrictions). Those take precedence for work inside that repository; this file describes the workspace as a whole.
