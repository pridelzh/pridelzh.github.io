# PrideLzh Research Blog Design

## 1. Purpose

Build a durable personal research blog and knowledge base at
`https://pridelzh.github.io`. The site is for sustained writing about:

- Computer Vision
- Medical AI
- Multimodal Learning
- Large Language Models
- Paper Reading
- Programming
- Research Thoughts

The site prioritizes readable text, chronological accumulation, and stable
navigation. It is not a portfolio landing page and does not use animation,
marketing sections, dashboards, or decorative interaction.

## 2. Technical Architecture

The site uses:

- GitHub Pages for hosting and deployment
- Jekyll for static-site generation
- Markdown for pages and posts
- Liquid for archive, category, and post-list generation
- Rouge for code highlighting
- MathJax for LaTeX rendering
- The GitHub Pages-supported `jekyll-feed` plugin for RSS
- A single custom CSS stylesheet for layout and typography

The site does not use Node.js, React, Vue, a database, a backend service, or a
client-side application framework.

The default branch is `main`. GitHub Pages builds the root of that branch after
each push. A local Ruby workflow is available through `Gemfile` for previewing
and validating the same site before publishing.

## 3. Visual Direction

The selected direction is a classic academic two-column layout inspired by
Terence Tao's “What's New” blog:

- White content surface on a very light warm-gray page background
- Dark neutral body text
- Restrained wine-red links and headings
- Serif type for titles and prose
- Sans-serif type for navigation, dates, labels, and metadata
- Thin borders instead of cards, shadows, gradients, or illustrations
- Desktop content area centered at approximately 960 pixels
- Main article column wider than the research-navigation sidebar
- Single-column layout below the tablet breakpoint
- Comfortable line height and constrained prose width for long reading sessions

The site header contains the title, subtitle, and four primary navigation links:
Home, About, Archive, and Categories.

## 4. Information Architecture

### Home (`/`)

The home page contains:

1. Site title and subtitle
2. A short research-student introduction
3. The eight most recent posts with date, title, category, tags, and excerpt
4. A native HTML `<details>` control labeled “More posts”
5. Inside the expanded section, all older posts as a compact date-and-title list
6. A link to the complete archive
7. A sidebar with research categories and post counts
8. A compact About block and year-archive links

The expanded older-post list is rendered statically by Liquid. It requires no
JavaScript and remains keyboard accessible. Recent posts carry richer metadata;
older posts remain compact so the expanded home page is still easy to scan.

If there are no posts, the home page displays a short message explaining that
research notes will appear there.

### About (`/about/`)

The About page uses a concise research-student profile:

- Name: PrideLzh
- Education: Computer Science
- Research interests:
  - Computer Vision
  - Medical AI
  - Multimodal Learning
  - Foundation Models
- Links:
  - GitHub: `https://github.com/pridelzh`
  - Email: `mailto:your-email@example.com`
  - Google Scholar: `https://scholar.google.com/`

The email and Scholar values are deliberately easy-to-replace starter values.
The README identifies the exact configuration fields to edit.

### Archive (`/archive/`)

The archive groups posts by year, shows the post count for each year, and lists
posts in reverse chronological order. Each entry contains the publication date
and title.

### Categories (`/categories/`)

The page presents “AI” as an umbrella heading with these stable research areas:

1. Computer Vision
2. Medical AI
3. Multimodal Learning
4. Large Language Models
5. Paper Reading
6. Programming
7. Research Thoughts

All seven areas remain visible even when their post count is zero. Posts use one
of these concrete areas as their primary category rather than creating nested
category URLs. Tags provide narrower concepts such as “Transformer”,
“Segmentation”, or “Evaluation”.

### Post pages

Each post shows:

- Title
- Publication date
- Category
- Tags
- Markdown body
- A link back to the archive

Posts do not include comments, reactions, page-view counters, advertising, or
third-party social widgets.

### 404 page

A small custom page explains that the requested note was not found and provides
links to Home, Archive, and Categories.

### RSS feed

Jekyll Feed generates `/feed.xml` from the same post collection. The default
layout advertises the feed in document metadata, and the footer exposes a normal
RSS link for readers who prefer feed subscriptions.

## 5. Content Model

Posts live in `_posts/` and follow Jekyll's filename convention:

```text
YYYY-MM-DD-short-slug.md
```

The required front matter is:

```yaml
---
layout: post
title: "Understanding Transformer"
date: 2026-07-31
categories:
  - Large Language Models
tags:
  - Transformer
  - Deep Learning
excerpt: "A concise research note on the Transformer architecture."
---
```

`excerpt` is recommended but optional. When it is absent, Jekyll generates an
excerpt from the first paragraph. Categories and tags are displayed only when
present, so an incomplete optional field does not create an empty label.

The permalink scheme is:

```text
/notes/:year/:month/:day/:title/
```

This keeps article URLs stable and distinguishes durable notes from the site's
top-level pages.

## 6. Templates and Files

The implementation creates:

```text
.
├── .gitignore
├── 404.md
├── Gemfile
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
│       └── specs/
│           └── 2026-07-31-research-blog-design.md
└── index.md
```

File responsibilities:

- `_config.yml`: site identity, links, permalink, Markdown, feed, and build settings
- `_includes/header.html`: site title and primary navigation
- `_includes/footer.html`: copyright and platform attribution
- `_includes/post-meta.html`: reusable date, category, and tag rendering
- `_layouts/default.html`: document shell, metadata, stylesheet, and MathJax
- `_layouts/home.html`: recent posts, expandable older posts, and sidebar
- `_layouts/page.html`: consistent top-level content pages
- `_layouts/post.html`: individual research-note presentation
- `index.md`: home-page front matter and introduction
- `about.md`: personal academic profile
- `archive.md`: Liquid-generated year archive
- `categories.md`: Liquid-generated stable research-area index
- `404.md`: navigation recovery page
- `style.css`: typography, layout, code, formula, and responsive rules
- `README.md`: writing, local preview, migration, and GitHub Pages deployment
- `Gemfile`: optional local Jekyll environment using the GitHub Pages gem

## 7. Rendering and Resilience

- HTML is semantic and remains readable without JavaScript.
- The main navigation uses normal links and works at every viewport width.
- `<details>` provides native open and closed states for older posts.
- Long code lines scroll horizontally instead of widening the page.
- Tables scroll within the article area on small screens.
- Images scale down to the available content width.
- MathJax display equations can scroll horizontally when necessary.
- Missing optional post metadata is omitted without leaving empty punctuation.
- Empty post collections and empty categories have explicit messages.
- Internal URLs use Jekyll's `relative_url` filter so the site also works in a
  local preview.

## 8. Verification

Before publication:

1. Run a clean Jekyll production build with `JEKYLL_ENV=production`.
2. Confirm the build exits successfully without Liquid or front-matter errors.
3. Check that Home, About, Archive, Categories, the sample post, and 404 output
   files exist in `_site/`.
4. Check generated internal links and confirm they resolve to generated files.
5. Confirm the sample post renders a fenced code block and inline and display
   LaTeX source.
6. Render and visually inspect the home page and sample post at desktop and
   mobile widths.
7. Confirm the default eight-post branch and the expandable older-post branch
   both have explicit tests using temporary fixture posts.

## 9. Deployment and Migration

The target repository is `git@github.com:pridelzh/pridelzh.github.io.git`.
Because this repository is currently empty, implementation starts in a fresh
local directory and does not touch the separate Hexo working directory.

The README provides two deployment paths:

1. For an empty repository, commit the Jekyll site and push `main`.
2. For a repository that later contains Hexo output, back up any desired
   Markdown, remove the old tracked Hexo files, add the Jekyll files, and commit
   the replacement.

GitHub repository settings use Pages → Build and deployment → Deploy from a
branch, with branch `main` and folder `/ (root)`. After the Pages build
completes, the public URL is `https://pridelzh.github.io`.

## 10. Scope Boundaries

The first version includes the complete writing and browsing foundation. It
does not include search, pagination, comments, analytics, a publication list,
dark mode, multilingual routing, or automatic citation management. These can be
added later only when real content creates a demonstrated need.
