# Migrazione a Cloudflare Pages

> [!WARNING]
> **Il progetto `marini-didattica-admin` è pubblico finché non configuri
> Cloudflare Access.** Il pulsante "Enable access policy" di Pages protegge solo
> i preview: per proteggere l'hostname di produzione `pages.dev` e il custom
> domain `admin.didattica.mattia-marini.com` servono i passaggi della sezione 6.
> Verifica con `curl -I`: entrambi gli URL devono rispondere `302` verso
> `*.cloudflareaccess.com`, non `200`.

Tutti i siti deployabili sono stati spostati da GitHub Pages a **Cloudflare
Pages**. Ogni sito è un progetto separato e viene pubblicato sul proprio
hostname `*.pages.dev` gratuito. Non serve comprare un dominio.

## Hostname

| Repository | Progetto Cloudflare | URL |
|---|---|---|
| `marini-didattica.github.io` | `marini-didattica-site` | <https://marini-didattica-site.pages.dev/> |
| `materiale` (pubblico/studenti) | `marini-didattica-materiale` | <https://marini-didattica-materiale.pages.dev/> |
| `materiale` (docente) | `marini-didattica-admin` | <https://marini-didattica-admin.pages.dev/> |
| `checker` | `marini-didattica-checker` | <https://marini-didattica-checker.pages.dev/> |
| `slide-seconde` (tutte le slide) | `marini-didattica-slides` | <https://marini-didattica-slides.pages.dev/> |

I deck sono serviti sotto `/<track>/<deck>/`, ad esempio
`https://marini-didattica-slides.pages.dev/prime/1-introduzione-python/`.
I vecchi repository `slide-prime`, `slide-olimpiadi` e `slide-extra` sono stati
uniti in `slide-seconde` e non vengono più deployati.

I nomi `pages.dev` sono globali: se uno è già occupato, scegline un altro nel
dashboard e aggiornalo in:

- `.github/workflows/deploy.yml` del repository;
- `materiale/src/consts.ts`;
- `marini-didattica.github.io/src/consts.ts` e i link nelle pagine
  `prime.astro`, `seconde.astro`, `olimpiadi.astro`, `area-riservata.astro`.

## Perché non `marini-didattica.github.io`

`*.github.io` è un dominio di GitHub. Non puoi puntarlo a Cloudflare né
proteggerlo con Cloudflare Access. Il sostituto gratuito è `*.pages.dev`, che
Cloudflare assegna a ogni progetto. Un dominio personalizzato è solo un
miglioramento estetico e si può aggiungere in seguito senza rifare nulla.

## Cosa fare, una volta sola

### 1. Account Cloudflare

Crea un account gratuito su <https://dash.cloudflare.com/sign-up>. Non serve
una carta di credito.

### 2. Crea gli otto progetti

Nel dashboard: **Workers & Pages → Create → Pages → Upload assets** (Direct
Upload). Per ogni nome della tabella qui sopra crea un progetto vuoto con
`production branch = main`.

In alternativa, da terminale:

```sh
npx wrangler login
npx wrangler pages project create marini-didattica-site --production-branch=main
npx wrangler pages project create marini-didattica-materiale --production-branch=main
npx wrangler pages project create marini-didattica-admin --production-branch=main
npx wrangler pages project create marini-didattica-checker --production-branch=main
npx wrangler pages project create marini-didattica-slides --production-branch=main
```

I workflow non creano i progetti: se il progetto non esiste, `wrangler pages
deploy` fallisce.

Se avevi già creato i quattro progetti `marini-didattica-slide-prime`,
`-slide-seconde`, `-slide-olimpiadi` o `-slide-extra`, cancellali: ora esiste
solo `marini-didattica-slides`.

### 3. Token API

Dashboard → **My Profile → API Tokens → Create Token → Create Custom Token**:

- Permissions: **Account → Cloudflare Pages → Edit**
- Account Resources: il tuo account
- Zone Resources: nessuna (non serve finché usi `pages.dev`)

Copia il token e l'**Account ID** (nella home del dashboard, colonna destra).

### 4. Secret su GitHub

In **ogni** repository: **Settings → Secrets and variables → Actions → New
repository secret**:

- `CLOUDFLARE_API_TOKEN`
- `CLOUDFLARE_ACCOUNT_ID`

I workflow usano `cloudflare/wrangler-action@v3` e non richiedono altri
segreti.

### 5. Rendi privato `materiale`

Il repository `materiale` contiene `content/students.json` (codici e nomi) e i
sorgenti riservati. Finché è pubblico, nessuna protezione del sito ha senso.
Rendilo privato: **Settings → General → Danger Zone → Change visibility →
Private**. Cloudflare Pages non ne ha bisogno per il deploy via GitHub Actions.

I file sono già nella storia Git. Dopo aver fatto un backup, valuta la pulizia
della storia con `git filter-repo` e considera compromessi i codici già
pubblicati. Le altre repository possono restare pubbliche.

### 6. Attiva Access sul progetto admin

Il progetto admin contiene solo materiale del docente, quindi va protetto **per
intero**, non per path. Cloudflare Pages ha un pulsante che protegge i preview;
per proteggere anche l'hostname di produzione `*.pages.dev` servono due passaggi
in più (sono le istruzioni ufficiali di Cloudflare per i "Known issues" di
Pages).

1. **Workers & Pages → marini-didattica-admin → Settings → Enable access
   policy**. Questo crea l'applicazione Access e protegge i preview.
2. **Manage** sull'applicazione appena creata → **Access → Applications** →
   seleziona il progetto → **Configure**.
3. In **Public hostname → Subdomain** cancella il wildcard `*`, lascia
   `marini-didattica-admin.pages.dev` e salva. Ora è protetto l'hostname di
   produzione.
4. Torna su **Settings → General → Enable access policy** e riattivalo, così
   vengono protetti anche i preview.
5. Verifica che esistano due applicazioni: una per
   `marini-didattica-admin.pages.dev` e una per
   `*.<project>.pages.dev`.
6. Crea una **seconda** Access application self-hosted per il custom domain
   `admin.didattica.mattia-marini.com`, con la stessa policy.

Policy (uguale per entrambe):

- **Allow** → **Emails** → la tua email
- Login: **One-time PIN** via email (non serve Google/GitHub)

Se il progetto non ha preview abilitati, il passaggio 4 non serve.

Verifica:

```sh
curl -I https://marini-didattica-admin.pages.dev/admin/
curl -I https://admin.didattica.mattia-marini.com/admin/
```

Entrambi devono rispondere `302` verso `*.cloudflareaccess.com`. Se rispondono
`200`, il materiale del docente è pubblico.

**Fallo prima del primo deploy del progetto admin.** Per evitare esposizioni
accidentali, il job "Deploy admin site" è disattivato finché non imposti la
variabile di repository `DEPLOY_ADMIN=true`.

Ordine corretto:

1. crea il progetto `marini-didattica-admin` (vuoto, come da passo 2);
2. configura Access sul progetto (passi sopra);
3. imposta **Settings → Secrets and variables → Actions → Variables → New
   repository variable** → `DEPLOY_ADMIN` = `true`;
4. fai partire il workflow: il primo deploy admin nasce già protetto.

Se il dashboard non permette di configurare Access su un progetto senza
deployment, pubblica prima una pagina placeholder innocua con
`npx wrangler pages deploy <cartella-con-index.html> --project-name=marini-didattica-admin`,
configura Access, verifica il login e solo allora imposta `DEPLOY_ADMIN=true`.
Non pubblicare mai `dist-admin` prima che Access sia attivo.

Il custom domain `admin.didattica.mattia-marini.com` esiste già: va protetto con
la sua Access application. Se in futuro aggiungi altri domini, aggiungili
**prima** di creare l'Access application: Cloudflare non permette di aggiungere
un custom domain a un hostname che ha già una policy Access attiva.

### 7. Verifica

Dopo il primo push su `main` di ogni repository:

| Controllo | Atteso |
|---|---|
| `https://marini-didattica-admin.pages.dev/` | login Access, poi redirect a `/admin/` |
| `https://marini-didattica-admin.pages.dev/admin/` | login Access |
| `https://marini-didattica-materiale.pages.dev/admin/` | 404 |
| `https://marini-didattica-materiale.pages.dev/raw/private/MRNMTT03/...` | 404 |
| `https://marini-didattica-materiale.pages.dev/private/<codice>/` | accesso diretto, senza login |
| `https://marini-didattica-materiale.pages.dev/raw/private/<codice>/...` | accesso diretto |
| `https://marini-didattica-site.pages.dev/` | sito principale |
| `https://marini-didattica-site.pages.dev/prime/` | link ai deck su `marini-didattica-slides.pages.dev` |
| `https://marini-didattica-slides.pages.dev/` | pagina indice con tutti i deck |
| `https://marini-didattica-slides.pages.dev/prime/1-introduzione-python/` | deck Prime |

Il codice studente resta un token nell'URL: chi lo riceve apre il materiale,
senza login. È il modello richiesto.

### 8. Spegni GitHub Pages

Solo dopo aver verificato i nuovi hostname: in ogni repository
**Settings → Pages → Unpublish site** (o disabilita la source). Il vecchio
deploy resta online finché non lo rimuovi.

### 9. Dominio personalizzato (opzionale, in seguito)

1. Compra un dominio (circa 10–15 €/anno; `.com` su Cloudflare Registrar è
   ~11 $/anno, `.it` ~12 € + IVA).
2. Aggiungilo a Cloudflare e cambia i nameserver presso il registrar.
3. In ogni progetto Pages: **Custom domains → Set up a domain**, ad esempio
   `marini-didattica.com`, `materiale.marini-didattica.com`,
   `admin.marini-didattica.com`, `slides.marini-didattica.com`.
4. Aggiorna gli stessi file elencati sopra con i nuovi URL.
5. Aggiungi una Access application per `admin.marini-didattica.com` e mantieni
   protetto anche `marini-didattica-admin.pages.dev` (o rimuovilo).

## Struttura del deploy `materiale`

`bun run build:deploy` produce due cartelle:

- `dist-public/`: sito pubblico e studenti. **Non contiene** `/admin` né i file
  della cartella staff.
- `dist-admin/`: copia completa con `/admin` e i file staff. Viene pubblicata
  solo sul progetto protetto da Access.

La cartella staff è quella con `"staff": true` in `content/students.json`
(attualmente `admin`, codice `MRNMTT03`). Le pagine pubbliche `/private/<codice>`
non vengono generate per le cartelle staff.

## Nota sulla build Typst

La build di `materiale` può fallire con:

```text
error: the argument `top` is positional
  ┌─ typst-components/src/documents/exam.typ:564:4
```

È un disallineamento preesistente tra il submodule `typst-components` e il
contenuto, non causato dalla migrazione. Va risolto prima del deploy: aggiorna
il submodule o correggi la chiamata `cover(top: top, ...)` in
`typst-components/src/documents/exam.typ`.

## Costi

- Cloudflare Pages: piano Free, 500 build/mese, 20.000 file per deploy,
  25 MiB per file, richieste statiche illimitate.
- Cloudflare Access: Free fino a 50 utenti.
- Dominio: 0 € finché usi `*.pages.dev`; ~10–15 €/anno se lo compri.
