# PrideLzh Research Blog

This repository is the source of a lightweight personal research blog for
notes on AI, computer vision, medical intelligence, multimodal learning, and
related engineering work. GitHub Pages builds the site with Ruby and Jekyll;
Liquid templates assemble the pages, Kramdown renders Markdown and LaTeX,
Rouge highlights code, MathJax 3 displays formulas, and a single CSS file
provides the responsive layout. The `github-pages` gem keeps the local toolchain
compatible with the production builder.

The target public URL is <https://pridelzh.github.io>.

## Repository structure

The maintained source tree is:

```text
.
├── .gitignore
├── 404.md
├── Gemfile
├── Gemfile.lock
├── README.md
├── _config.yml
├── _includes/
│   ├── footer.html
│   ├── header.html
│   └── post-meta.html
├── _layouts/
│   ├── default.html
│   ├── home.html
│   ├── page.html
│   └── post.html
├── _posts/
│   └── 2026-07-31-understanding-transformer.md
├── about.md
├── archive.md
├── assets/
│   └── css/
│       └── style.css
├── categories.md
├── docs/
│   └── superpowers/
│       ├── plans/
│       │   └── 2026-07-31-research-blog-implementation.md
│       └── specs/
│           └── 2026-07-31-research-blog-design.md
├── index.md
└── test/
    ├── content_pages_test.rb
    ├── home_test.rb
    ├── layout_test.rb
    ├── readme_test.rb
    ├── site_config_test.rb
    └── test_helper.rb
```

- `.gitignore` excludes generated builds, local dependency caches, worktrees,
  and task-control files.
- `404.md` supplies the not-found page and links visitors back into the site.
- `Gemfile` declares the GitHub Pages-compatible Ruby dependency set.
- `Gemfile.lock` pins the resolved Ruby gems for repeatable local builds.
- `README.md` is the operator guide for writing, testing, migration, and
  deployment.
- `_config.yml` holds site identity, profile links, URL and permalink settings,
  Markdown options, research categories, and plugins.
- `_includes/header.html` renders the site title and primary navigation.
- `_includes/footer.html` renders the copyright, RSS, and platform links.
- `_includes/post-meta.html` renders reusable dates, categories, and tags.
- `_layouts/default.html` provides the HTML shell, metadata, stylesheet, feed,
  and MathJax setup.
- `_layouts/home.html` renders recent-post previews, older posts, and the
  research-area sidebar.
- `_layouts/page.html` wraps top-level informational pages consistently.
- `_layouts/post.html` renders an individual research note.
- `_posts/2026-07-31-understanding-transformer.md` is the sample research post.
- `about.md` contains the academic profile and external profile links.
- `archive.md` generates the year-grouped post archive.
- `assets/css/style.css` provides typography, two-column layout, code, formula,
  and responsive styling.
- `categories.md` generates the stable research-area index.
- `docs/superpowers/plans/2026-07-31-research-blog-implementation.md` records the
  implementation and verification plan.
- `docs/superpowers/specs/2026-07-31-research-blog-design.md` records the agreed
  site design and scope.
- `index.md` provides home-page front matter and the introductory text.
- `test/content_pages_test.rb` builds and checks content pages, post rendering,
  and internal links.
- `test/home_test.rb` checks the recent/older post split and the empty state.
- `test/layout_test.rb` checks navigation, assets, MathJax, and responsive CSS.
- `test/readme_test.rb` protects the essential operator workflow.
- `test/site_config_test.rb` checks public identity, build settings, and ordered
  research categories.
- `test/test_helper.rb` creates isolated temporary Jekyll builds for tests.

`_site/`, `.jekyll-cache/`, `.bundle/`, and `vendor/` are local generated or
dependency directories. They are deliberately ignored and are not maintained
source files.

## Create a new post

Create each note under `_posts/` with the filename convention
`_posts/YYYY-MM-DD-short-slug.md`. Use lowercase words separated by hyphens in
the slug. For example:

````markdown
---
layout: post
title: "Calibrating a Medical Image Classifier"
date: 2026-08-01
categories:
  - Medical AI
tags:
  - Calibration
  - Computer Vision
excerpt: "A practical note on calibration error and temperature scaling."
---

## Motivation

For class probabilities $p_k$, confidence is $\max_k p_k$.

$$
\operatorname{ECE}
= \sum_{m=1}^{M}\frac{|B_m|}{n}
  \left|\operatorname{acc}(B_m)-\operatorname{conf}(B_m)\right|
$$

```python
def temperature_scale(logits, temperature):
    return logits / temperature
```

![Reliability diagram]({{ '/assets/images/reliability-diagram.png' | relative_url }})
````

Authoring rules:

- Keep the filename date and the `date` front-matter value aligned.
- Use `layout: post`. `title` and `date` are required.
- Write `categories` and `tags` as YAML lists, even when there is only one
  value. Prefer a category already listed in `_config.yml` under
  `research_categories`.
- `excerpt` is recommended for a controlled home-page summary; without it,
  Jekyll uses the first paragraph.
- Use fenced code blocks with a language name such as `python`, `ruby`, or
  `bash` so Rouge can highlight them.
- Put images in `assets/images/` (create it when first needed) and pass their
  path through Liquid's `relative_url` filter, for example
  `![Alt text]({{ '/assets/images/example.png' | relative_url }})`. Use
  descriptive alt text and commit the image with the post.
- Write inline LaTeX between `$...$`. Write display equations between `$$`
  delimiters on their own lines, as in the example; MathJax 3 is loaded by the
  default layout.
- Preview the post and inspect its generated URL. The configured permalink is
  `/notes/:year/:month/:day/:title/`.

## Install and preview locally

Run all commands from the repository root. Check Ruby, install Bundler if it is
not already available, install the locked dependencies, and start Jekyll:

```bash
ruby --version
gem --version
gem install bundler
bundle config set --local path vendor/bundle
bundle install
bundle exec jekyll serve
```

Open <http://127.0.0.1:4000/>. The server watches source files by default; stop
it with `Ctrl+C`. After changing `_config.yml`, restart the server because
Jekyll does not reliably reload configuration changes.

## Build and test

Run the focused README contract with:

```bash
bundle exec ruby -Itest test/readme_test.rb
```

Run the complete Minitest suite with:

```bash
bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |file| require_relative file }'
```

Make a clean production build before publishing:

```bash
bundle exec jekyll clean
JEKYLL_ENV=production bundle exec jekyll build --trace
```

A successful build writes the generated site to `_site/`. Do not commit that
directory; GitHub Pages builds from the Jekyll source.

## Replace an old Hexo site safely

These steps replace only the GitHub Pages repository
`git@github.com:pridelzh/pridelzh.github.io.git`. They must never be run in, or
against, a separate local Hexo working directory such as `Blog`. Leave that
independent directory untouched.

1. **Back up before changing anything.** From a neutral parent directory, make
   a full mirror of the remote repository. Choose a durable backup path:

   ```bash
   BACKUP_DIR="/absolute/path/to/backups/pridelzh.github.io-before-jekyll.git"
   git clone --mirror git@github.com:pridelzh/pridelzh.github.io.git "$BACKUP_DIR"
   ```

   If the old Hexo site has unpushed posts or other wanted Markdown, copy those
   files into the backup separately before continuing. Confirm the mirror
   exists with `git --git-dir="$BACKUP_DIR" show-ref`.

2. **Use a fresh migration clone and check the exact target.** Do not reuse the
   independent `Blog` directory:

   ```bash
   MIGRATION_DIR="$(mktemp -d)/pridelzh.github.io"
   git clone git@github.com:pridelzh/pridelzh.github.io.git "$MIGRATION_DIR"
   cd "$MIGRATION_DIR"

   test "$(git rev-parse --show-toplevel)" = "$MIGRATION_DIR"
   test "$(git remote get-url origin)" = "git@github.com:pridelzh/pridelzh.github.io.git"
   git status --short --branch
   ```

   Stop immediately if either `test` command fails, if the repository is not
   the exact Pages repository, or if it contains unexpected local changes.

3. **Stage the replacement only in the verified migration clone.** Set
   `JEKYLL_SOURCE` to the absolute path of this reviewed Jekyll source tree,
   then remove the old repository's tracked Hexo files and copy the Jekyll
   source:

   ```bash
   JEKYLL_SOURCE="/absolute/path/to/reviewed/pridelzh.github.io"
   test -f "$JEKYLL_SOURCE/_config.yml"
   test -f "$JEKYLL_SOURCE/Gemfile"

   git rm -r -- .
   rsync -a \
     --exclude="/.git" \
     --exclude=".bundle/" \
     --exclude=".jekyll-cache/" \
     --exclude=".superpowers/" \
     --exclude=".worktrees/" \
     --exclude="_site/" \
     --exclude="vendor/" \
     "$JEKYLL_SOURCE/" ./
   git status --short
   ```

   Review every deletion and addition shown by `git status`. Restore any
   wanted old Markdown into `_posts/` and convert it to the Jekyll front matter
   described above. Do not commit until the full tests and production build
   pass.

4. **Commit and push the reviewed replacement:**

   ```bash
   git add -A
   git diff --cached --stat
   git diff --cached
   git commit -m "feat: replace Hexo site with Jekyll research blog"
   git branch -M main
   git push -u origin main
   ```

The mirror backup can restore any committed branch or tag if the replacement
needs to be rolled back.

## Deploy to GitHub Pages

For this Jekyll root, verify the configured remote and publish `main`:

```bash
git remote get-url origin
# Expected: git@github.com:pridelzh/pridelzh.github.io.git

git status
git add -A
git diff --cached
git commit -m "docs: publish research note"
git branch -M main
git push -u origin main
```

If there is nothing new to commit, skip the `git add` and `git commit` lines
and push the existing commit. In the GitHub repository:

1. Open **Settings** → **Pages**.
2. Under **Build and deployment**, set **Source** to **Deploy from a branch**.
3. Select branch **main** and folder **/ (root)**.
4. Click **Save**, then watch the Pages deployment in the repository's
   **Actions** tab.

The expected public URL is <https://pridelzh.github.io>. A first deployment
usually takes a few minutes; allow about 10 minutes before treating a missing
or stale page as a failure. Later pushes to `main` trigger a new Pages build.

## Update the email and Google Scholar links

The placeholder values are in `_config.yml`:

```yaml
email: "your-email@example.com"
scholar_url: "https://scholar.google.com/"
```

Replace both values with the real public profile information, preserving the
field names and YAML quotes:

```yaml
email: "your-public-email@example.com"
scholar_url: "https://scholar.google.com/citations?user=YOUR_SCHOLAR_ID"
```

Restart the local preview, check the About page and footer links, run the full
test suite and production build, then commit and push the `_config.yml` change.
