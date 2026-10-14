# Project structure
This is a multi-repo organization for school material. The project structure is the following:
.
├── marini-didattica.github.io: astro landing page that serves as a dashboard, redirrecting to the hosted slides and material
├── misc: misc materials, mainly typst documents
├── slide-prime: slidev slide decks
├── slide-seconde: slidev slide decks
├── extra-slides: extra slidev slide decks
├── slidev-addons: addons used by all decks in the workspace
├── slidev-theme: slidev theme used by all decks in the workspace 
└── workspace-meta: collection of scripts and utils to coordinate the multirepo agentic workslows

slide-prime, slide-seconde, extra-slides, misc all have github actions deploing the artifact to github pages; each artifact will be referenced from a dashboard entry in the marini-didattica.github.io site

# Workflows
The vast majority of work will be slide creation. Changes should target the ecosystem as a whole; if I require to update the look of something that should be put in the theme repo; if a new component is needed, then put it in the addons repo if that makes sense.

Each slidev deck can be started with `cd slidev-project && bun run dev src/deck-name/0-main.md -p <port>. User ports from 3130 on

When a multi deck modification is needed you can start multiple servers in parallel

# Don't
Don't update bun dependencies, only update the slidev-theme-russell and slidev-addons-russell, whenever you updated them 

# VCS
Use conventional commit messages: feat|chore|fix|docs|refactor|test (context): message. Keep them coincise and avoid using a context if not strictly necessary
