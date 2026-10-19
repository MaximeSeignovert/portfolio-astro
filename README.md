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

## Différences avec la version React

- Plus de TanStack Router ni de React : une seule page statique (`src/pages/index.astro`).
- `src/sections/Formation.tsx` du repo React n'était **pas rendu** dans `routes/index.tsx` (code mort). Il n'a pas été porté ; le bloc « Formation » est déjà présent dans la section À propos.
- Le footer indique désormais « Construit avec Astro & Tailwind ».
- Le bouton mobile du menu et le drawer projet ont été réécrits en JavaScript vanilla.
