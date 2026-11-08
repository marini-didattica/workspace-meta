# Migrazione a Cloudflare Pages

> [!WARNING]
> **Il progetto `marini-didattica-admin` è protetto da una pagina di login e da
> una sessione firmata HttpOnly.** Se `ADMIN_USER` e `ADMIN_PASS` non sono
> configurati, il worker risponde `503` (fail closed) e non serve alcun
> contenuto. La password non va mai nel repository: il repository `materiale` è
> pubblico. Vedi la sezione 6.

Tutti i siti deployabili sono stati spostati da GitHub Pages a **Cloudflare
Pages**. Ogni sito è un progetto separato. Il dominio personalizzato è
`didattica.mattia-marini.com`; ogni progetto conserva anche il proprio
hostname `*.pages.dev` come fallback.

## Hostname

| Repository | Progetto Cloudflare | URL |
|---|---|---|
| `marini-didattica.github.io` | `marini-didattica-site` | <https://didattica.mattia-marini.com/> |
| `materiale` (pubblico/studenti) | `marini-didattica-materiale` | <https://materiale.didattica.mattia-marini.com/> |
| `materiale` (docente) | `marini-didattica-admin` | <https://admin.didattica.mattia-marini.com/> |
| `checker` | `marini-didattica-checker` | <https://checker.didattica.mattia-marini.com/> |
| `slides` (tutte le slide) | `marini-didattica-slides` | <https://slides.didattica.mattia-marini.com/> |

I deck sono serviti sotto `/<track>/<deck>/`, ad esempio
`https://slides.didattica.mattia-marini.com/prime/1-introduzione-python/`.
I vecchi repository `slide-prime`, `slide-olimpiadi` e `slide-extra` sono stati
uniti in `slides` e non vengono più deployati.

`slides.didattica.mattia-marini.com` è già collegato al progetto Pages ma è in
attesa del record DNS. Aggiungi in Cloudflare:

```text
Tipo: CNAME
Nome: slides
Destinazione: marini-didattica-slides.pages.dev
Proxy: Proxied (nuvola arancione)
```

Finché il CNAME non esiste, i link alle slide usano un host che non risolve.
Gli hostname `*.pages.dev` restano comunque raggiungibili.

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

### 6. Configura il login del progetto admin

Il progetto admin è protetto **per intero** da una pagina di login Astro
(`/login/`) e da una sessione firmata `HttpOnly`. Il worker
`deploy/admin/_worker.js` viene copiato in `dist-admin/_worker.js` e controlla
ogni richiesta, inclusi i PDF e i file sotto `/raw/private/`. La pagina di login
usa lo stesso layout del sito; la build pubblica non la contiene.

Le credenziali sono variabili del progetto Pages, mai nel repository:

1. **Workers & Pages → marini-didattica-admin → Settings → Variables and
   Secrets**.
2. Nell'ambiente **Production** (e **Preview** se usi i preview) aggiungi:
   - `ADMIN_USER` — testo, ad esempio `admin`
   - `ADMIN_PASS` — **secret**, una password lunga e casuale
     (`openssl rand -base64 24`)
3. Salva. Se il dashboard lo richiede, rilancia il deployment.
4. Verifica:

   ```sh
   # Pagina di login pubblica (ma protetta dal worker: serve una sessione)
   curl -I https://admin.didattica.mattia-marini.com/login/
   # 200

   # /admin/ senza sessione: redirect alla pagina di login
   curl -I https://admin.didattica.mattia-marini.com/admin/
   # 303 Location: /login/?next=%2Fadmin%2F

   # Login via form (curl) e accesso con il cookie
   curl -i -c /tmp/admin-cookie \
     -d 'username=admin&password=LA_TUA_PASSWORD&next=/admin/' \
     https://admin.didattica.mattia-marini.com/__admin/login
   # 303 Location: /admin/ + Set-Cookie: __Host-admin_session=...

   curl -I -b /tmp/admin-cookie https://admin.didattica.mattia-marini.com/admin/
   # 200

   # Basic Auth resta disponibile per script
   curl -u admin:LA_TUA_PASSWORD -I https://admin.didattica.mattia-marini.com/admin/
   # 200
   ```

   `503` significa che `ADMIN_USER`/`ADMIN_PASS` non sono configurati.
   `200` su `/admin/` senza cookie significa che il worker non è nel deployment.

In alternativa da terminale:

```sh
npx wrangler pages secret put ADMIN_USER --project-name=marini-didattica-admin
npx wrangler pages secret put ADMIN_PASS --project-name=marini-didattica-admin
```

Note:

- La sessione dura 12 ore. Il pulsante **Esci** nell'area admin cancella il
  cookie.
- Il cookie è `__Host-admin_session`, `HttpOnly`, `Secure`, `SameSite=Strict`,
  firmato con HMAC-SHA256. La chiave deriva da `ADMIN_PASS`: cambiare la
  password invalida tutte le sessioni.
- Il cookie è per hostname: il login su `admin.didattica.mattia-marini.com` non
  vale su `marini-didattica-admin.pages.dev`. È normale.
- Usa una password lunga e casuale: non c'è blocco dopo tentativi falliti.
  Se vuoi, aggiungi una regola di rate limiting/WAF Cloudflare su
  `admin.didattica.mattia-marini.com`.
- Se avevi creato applicazioni Cloudflare Access per gli stessi hostname,
  rimuovile: altrimenti il browser chiederà due autenticazioni.
- Il worker vale per `pages.dev`, per il custom domain e per ogni deployment
  del progetto, compresi i preview.

Il job "Deploy admin site" è disattivato finché non imposti la variabile di
repository `DEPLOY_ADMIN=true`. Puoi impostarla anche subito: se le credenziali
non sono ancora configurate, il sito risponde `503` e non espone nulla.

### 7. Verifica

Dopo il primo push su `main` di ogni repository:

| Controllo | Atteso |
|---|---|
| `https://admin.didattica.mattia-marini.com/login/` senza sessione | `200` (pagina di login) |
| `https://admin.didattica.mattia-marini.com/admin/` senza sessione | `303` verso `/login/?next=...` |
| `https://admin.didattica.mattia-marini.com/admin/` con sessione valida | `200` |
| `https://admin.didattica.mattia-marini.com/admin/` senza sessione | `303` verso `/login/` |
| `https://admin.didattica.mattia-marini.com/raw/private/MRNMTT03/...` senza sessione | `303` |
| `https://admin.didattica.mattia-marini.com/login/` | `503` se `ADMIN_USER`/`ADMIN_PASS` mancano |
| `https://materiale.didattica.mattia-marini.com/login/` | `404` |
| `https://materiale.didattica.mattia-marini.com/admin/` | `404` |
| `https://materiale.didattica.mattia-marini.com/raw/private/MRNMTT03/...` | `404` |
| `https://materiale.didattica.mattia-marini.com/private/<codice>/` | accesso diretto, senza login |
| `https://materiale.didattica.mattia-marini.com/raw/private/<codice>/...` | accesso diretto |
| `https://didattica.mattia-marini.com/` | sito principale |
| `https://didattica.mattia-marini.com/prime/` | link ai deck su `marini-didattica-slides.pages.dev` |
| `https://slides.didattica.mattia-marini.com/` | pagina indice con tutti i deck |
| `https://slides.didattica.mattia-marini.com/prime/1-introduzione-python/` | deck Prime |

Il codice studente resta un token nell'URL: chi lo riceve apre il materiale,
senza login. È il modello richiesto.

### 8. Spegni GitHub Pages

Solo dopo aver verificato i nuovi hostname: in ogni repository
**Settings → Pages → Unpublish site** (o disabilita la source). Il vecchio
deploy resta online finché non lo rimuovi.

### 9. Dominio personalizzato

Il dominio è già configurato:

| Dominio | Progetto Pages |
|---|---|
| `didattica.mattia-marini.com` | `marini-didattica-site` |
| `materiale.didattica.mattia-marini.com` | `marini-didattica-materiale` |
| `admin.didattica.mattia-marini.com` | `marini-didattica-admin` |
| `checker.didattica.mattia-marini.com` | `marini-didattica-checker` |
| `slides.didattica.mattia-marini.com` | `marini-didattica-slides` (CNAME da aggiungere) |

Le pagine usano questi URL; gli `*.pages.dev` restano come fallback. Per
aggiungere un altro dominio: collegalo al progetto Pages, crea il record DNS,
poi aggiorna `materiale/src/consts.ts`, `marini-didattica.github.io/src/consts.ts`
e i link nelle pagine `prime.astro`, `seconde.astro`, `olimpiadi.astro`,
`area-riservata.astro`.

Non serve una Access application: login e sessione firmata proteggono
automaticamente ogni hostname del progetto admin, custom domain compreso. Se
aggiungi un dominio personalizzato, verifica che
`curl -I https://admin.<dominio>/admin/` risponda `303` verso `/login/`.

## Struttura del deploy `materiale`

`bun run build:deploy` produce due cartelle:

- `dist-public/`: sito pubblico e studenti. **Non contiene** `/admin`, i file
  della cartella staff, né `_worker.js`.
- `dist-admin/`: copia completa con `/admin`, i file staff, `login/` e
  `_worker.js`. Viene pubblicata solo sul progetto `marini-didattica-admin`; il
  worker applica login e sessione firmata a ogni richiesta.

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
- Login con sessione firmata (Pages Worker): incluso nel piano Free.
- Cloudflare Access (alternativa SSO, non usata): Free fino a 50 utenti.
- Dominio: ~10–15 €/anno.
