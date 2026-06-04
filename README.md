# Personal website

A minimalist, single-page academic site for Hiba Sameen. Plain HTML + CSS, no build step. Public GitHub repositories are listed automatically via the GitHub API.

## Edit content

Everything lives in `index.html`:

- **About / Research / CV** — edit the text directly in the relevant `<section>`.
- **Projects** — each project is a card in the `<section id="projects">` grid. To add one, copy an existing `<a class="card">…</a>` block and change the `href` (live site), `src` (thumbnail), title and description. Thumbnails can be a real image URL, or an auto-screenshot via `https://s0.wp.com/mshots/v1/<url-encoded-site>?w=1200`.
- **Links** — update the Google Scholar / GitHub / LinkedIn URLs in the header.
- **CV** — replace `CV_Anthropic_Research_Economist.pdf` (keep the filename, or update the link in the CV section).

## Publish on GitHub Pages

1. Create a repository. For a site at `https://<username>.github.io`, name it exactly `<username>.github.io`. For a project site at `https://<username>.github.io/<repo>`, use any name.
2. Push these files to the `main` branch:
   ```bash
   git init
   git add .
   git commit -m "Initial site"
   git branch -M main
   git remote add origin https://github.com/<username>/<repo>.git
   git push -u origin main
   ```
3. In the repo: **Settings → Pages → Build and deployment → Source → GitHub Actions**.
4. The included workflow (`.github/workflows/pages.yml`) deploys on every push to `main`. Your site goes live in ~1 minute.

The `.nojekyll` file disables Jekyll processing so files are served as-is.
