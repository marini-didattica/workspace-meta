# Workspace
This is a multi-repo workspace for school material. The repositories live side by side, each with its own git history; production sites are deployed to Cloudflare Pages. Layout:
.
├── prime: slidev slide decks (Prime class)
├── seconde: slidev slide decks (Seconde class)
├── extra-slides: extra slidev slide decks
├── materiale: unified public/reserved material host and file browser (replaces misc + riservato)
├── misc: legacy public typst documents, superseded by materiale
├── riservato: legacy reserved material, superseded by materiale
├── slidev-theme: slidev theme (marini-slidev-theme) used by every deck
├── slidev-addons: slidev addons (marini-slidev-addons) used by every deck
├── slide-site: astro dashboard linking the published slides and material
└── workspace-meta: scripts and configuration coordinating the multi-repo agentic workflow

Deck repos consume slidev-theme and slidev-addons as npm git dependencies. `slide-seconde` (repository `slides`) builds every deck and `materiale` builds the material site; both deploy to Cloudflare Pages from GitHub Actions. The old GitHub Pages sites (`marini-didattica.github.io`, `misc`, `riservato`, `materiale`, `checker`, `slide-prime`, `slide-olimpiadi`, `slide-extra`) are kept on purpose as redirect-only deployments: they are the only way to forward legacy `*.github.io` links to the new domain, so don't remove them (see `workspace-meta/CLOUDFLARE.md`, section 8). New public or reserved material belongs in materiale, under `content/raw/{public,private}`; don't add content to the legacy misc/riservato repos.

Source `workspace-meta/activate.fish` once per shell: it exports `OPENCODE_CONFIG` / `OPENCODE_CONFIG_DIR` and prepends `bin/` to `PATH`.

# Workflows
The vast majority of work is slide creation. Prefer changes that target the ecosystem as a whole: a visual change belongs in slidev-theme, a reusable component in slidev-addons.

Exam work uses two workspace agents: `corrector` normalizes answer folders, creates and fills `correzioni/` descriptors, and asks for the scoring grid; `checker` builds `misc/grafo-copie.json` from the completed corrections.

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
