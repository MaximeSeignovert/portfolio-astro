# Portfolio Astro — Maxime Seignovert

Portfolio personnel migré de React (Vite + TanStack Router) vers **Astro**, avec un objectif principal : le **SEO**.

Le site est **100 % statique** : tout le contenu (textes, expériences, projets) est rendu en HTML au build, sans hydratation React.

## Stack

| | |
|---|---|
| Framework | Astro 7 (`output: static`) |
| Styles | Tailwind CSS v4 (via `@tailwindcss/vite`) |
| Icônes | `@lucide/astro` (SVG inlinés, zéro JS) |
| Sitemap | `@astrojs/sitemap` |
| Interactivité | JavaScript vanilla (~2 Ko), uniquement pour le menu mobile et le drawer projet |

## Structure

```
public/
  psyduck.png          # favicon + og:image
  robots.txt           # + référence au sitemap
src/
  consts.ts            # métadonnées du site (SEO, liens sociaux)
  data/                # contenus (JSON, identiques au repo React)
    about.json
    experiences.json
    formations.json
    projets.json
  layouts/
    BaseLayout.astro   # <head>, métas, JSON-LD, slot
  components/
    Navigation.astro   # nav + menu mobile
    SectionHeader.astro
  sections/
    Hero.astro
    About.astro
    Experience.astro
    Projects.astro     # grille + drawer mobile
    Contact.astro
  pages/
    index.astro
  styles/
    global.css         # design system (thème oklch, grain, animations)
```

## Commandes

```bash
npm install
npm run dev      # serveur de dev
npm run build    # build statique dans dist/
npm run preview  # prévisualisation du build
npm run check    # type-check des fichiers .astro
```

## Ce qui a été fait pour le SEO

- **Rendu statique complet** : le HTML contient tout le contenu, les crawlers n'ont pas besoin d'exécuter de JS.
- `<html lang="fr">` et `scroll-smooth`.
- `<title>` unique + `<meta name="description">` (voir `src/consts.ts`).
- `<link rel="canonical">` généré depuis `site` dans `astro.config.mjs`.
- **Open Graph** + **Twitter Cards** complets (`og:title`, `og:description`, `og:image`, `og:locale`, `og:type`, `twitter:card`).
- **Données structurées JSON-LD** : `Person` (poste, employeur, `knowsAbout`, `alumniOf`, `sameAs`) et `WebSite`.
- **Sitemap XML** généré automatiquement à chaque build (`/sitemap-index.xml`).
- `robots.txt` avec référence au sitemap.
- HTML sémantique : un seul `<h1>`, sections `<section>` avec `id`, `<article>` pour les expériences, `<footer>`.
- Accessibilité : lien d'évitement (« Aller au contenu »), `aria-*` sur le menu et le drawer, focus visible, respect de `prefers-reduced-motion`.
- Performance : ~0 JS au chargement (hors scripts inline), CSS unique de ~28 Ko, icônes inlinées.

> ⚠️ Pense à mettre à jour `site` dans `astro.config.mjs` et `SITE.url` dans `src/consts.ts` si le domaine change.

## Déploiement (Coolify)

Le repo contient un **Dockerfile multi-stage** (`node:24-alpine` → `nginx:1.29-alpine`) et un `nginx.conf` (cache, gzip, en-têtes de sécurité).

> ⚠️ **Ne pas utiliser le build pack Nixpacks.** Le snapshot nixpkgs de Nixpacks est figé et ne fournit que Node 22.19.0, alors qu'Astro 7 exige Node ≥ 22.22.0 : le build échoue avec `Node.js v22.19.0 is not supported by Astro!`. Changer `.nvmrc` ou `NIXPACKS_NODE_VERSION` n'y remédie pas (Nixpacks mappe par version majeure).

Réglages côté Coolify :

| Réglage | Valeur |
|---|---|
| Build Pack | **Dockerfile** |
| Ports Exposes | `80` |
| Is it a static site? | ❌ décoché (le Dockerfile s'en charge) |
| Build Command / Publish Directory | vides (ignorés) |

Le build du site se fait **dans l'image** (`npm ci` + `npm run build`) : aucune commande à fournir à Coolify.

### Déploiement automatique (webhook)

L'application a été créée en **dépôt public** : Coolify n'a alors aucun accès à ton compte GitHub et **ne peut donc pas créer le webhook tout seul**. Il faut le déclarer à la main.

1. **Coolify** → ton application → onglet **Webhooks** → section *Manual Git Webhooks* : copie l'**URL**, et génère/copie le **secret**.
2. **GitHub** → page du repo → *Settings* → **Webhooks** → **Add webhook** :
   - *Payload URL* : l'URL copiée depuis Coolify
   - *Content type* : **`application/json`** (indispensable, sinon Coolify ne parse pas le payload)
   - *Secret* : le secret copié depuis Coolify
   - *SSL verification* : activé
   - *Which events?* : **Just the push event**
   - *Active* : ✅
3. Vérifie dans GitHub → *Webhooks* → **Recent Deliveries** : la réponse doit être `200`. Puis pousse un commit sur `main` → un déploiement doit apparaître dans Coolify.

> ⚠️ L'URL du webhook doit être **joignable depuis Internet** : c'est GitHub qui appelle ton Coolify, en sortant. Si l'URL contient `localhost` ou une IP privée, le webhook échouera toujours — expose Coolify derrière un domaine en HTTPS.

> Alternative : connecter un **GitHub App** dans Coolify (*Sources* → *GitHub App*). Coolify gère alors les webhooks automatiquement, et ça débloque aussi les dépôts privés et les *preview deployments*.

> Si Coolify répond `200` mais ne déploie rien : vérifie **Watch Paths** dans les réglages de l'application. Un chemin qui ne matche pas le fichier poussé fait silencieusement ignorer le push.

Pour builder/tester l'image en local :

```bash
docker build -t portfolio-astro .
docker run --rm -p 8080:80 portfolio-astro   # http://localhost:8080
```

## Différences avec la version React

- Plus de TanStack Router ni de React : une seule page statique (`src/pages/index.astro`).
- `src/sections/Formation.tsx` du repo React n'était **pas rendu** dans `routes/index.tsx` (code mort). Il n'a pas été porté ; le bloc « Formation » est déjà présent dans la section À propos.
- Le footer indique désormais « Construit avec Astro & Tailwind ».
- Le bouton mobile du menu et le drawer projet ont été réécrits en JavaScript vanilla.
