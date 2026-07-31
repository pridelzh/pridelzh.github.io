# PrideLzh Research Blog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and verify a maintainable academic Jekyll blog that publishes Markdown research notes at `https://pridelzh.github.io`.

**Architecture:** GitHub Pages builds a custom Jekyll site from `main`. Liquid layouts generate the home feed, expandable older-post list, category index, and year archive; Markdown supplies content; one CSS file supplies the responsive two-column academic design.

**Tech Stack:** GitHub Pages, Ruby, Jekyll, Liquid, Markdown/Kramdown, Rouge, MathJax 3, Minitest, HTML, CSS

## Global Constraints

- Use GitHub Pages, Jekyll, Markdown, Liquid templates, and simple CSS.
- Do not use Node.js, React, Vue, a database, or a backend service.
- Keep the site white, text-first, academic, responsive, and free of decorative animation.
- Publish new articles by adding `_posts/YYYY-MM-DD-short-slug.md`.
- Default the home page to eight rich post previews; expose all older posts through native HTML `<details>`.
- Keep the stable research areas: Computer Vision, Medical AI, Multimodal Learning, Large Language Models, Paper Reading, Programming, and Research Thoughts.
- Render code with Rouge and LaTeX with MathJax.
- Preserve the existing design specification at `docs/superpowers/specs/2026-07-31-research-blog-design.md`.

---

## File Map

- `.gitignore`: generated Jekyll, Bundler, and visual-companion artifacts
- `Gemfile`: GitHub Pages-compatible local Ruby dependencies
- `Gemfile.lock`: reproducible resolved Ruby dependency versions
- `_config.yml`: site identity, links, categories, Markdown, feed, and permalink settings
- `_includes/header.html`: title and primary navigation
- `_includes/footer.html`: copyright, RSS, and platform attribution
- `_includes/post-meta.html`: reusable post date/category/tag rendering
- `_layouts/default.html`: document shell, SEO metadata, CSS, feed metadata, and MathJax
- `_layouts/home.html`: recent previews, expandable older notes, sidebar, and empty state
- `_layouts/page.html`: top-level content pages
- `_layouts/post.html`: research-note article pages
- `assets/css/style.css`: full visual system and responsive behavior
- `index.md`: home front matter and introduction
- `about.md`: academic profile
- `archive.md`: year-grouped post archive
- `categories.md`: stable research-area listing
- `404.md`: navigation recovery
- `_posts/2026-07-31-understanding-transformer.md`: sample Markdown post
- `test/test_helper.rb`: temporary Jekyll build helper
- `test/site_config_test.rb`: configuration contract
- `test/layout_test.rb`: document-shell and CSS contract
- `test/home_test.rb`: eight-post and expandable-list behavior
- `test/content_pages_test.rb`: About, Archive, Categories, post, 404, and internal-link behavior
- `test/readme_test.rb`: writing and deployment documentation contract
- `README.md`: authoring, local preview, Hexo replacement, and Pages deployment guide

---

### Task 1: Lock the Site Configuration Contract

**Files:**

- Create: `test/site_config_test.rb`
- Create: `_config.yml`
- Create: `Gemfile`

**Interfaces:**

- Consumes: the research categories and public identity approved in the design specification
- Produces: `site.research_categories`, `site.author`, `site.email`, `site.scholar_url`, the `/notes/:year/:month/:day/:title/` permalink, and the `jekyll-feed` plugin configuration

- [ ] **Step 1: Write the failing configuration test**

```ruby
# test/site_config_test.rb
require "minitest/autorun"
require "date"
require "yaml"

class SiteConfigTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def setup
    @config = YAML.safe_load(
      File.read(File.join(ROOT, "_config.yml")),
      permitted_classes: [Date, Time],
      aliases: true
    )
  end

  def test_public_identity_and_build_settings
    assert_equal "PrideLzh Blog", @config.fetch("title")
    assert_equal "https://pridelzh.github.io", @config.fetch("url")
    assert_equal "/notes/:year/:month/:day/:title/", @config.fetch("permalink")
    assert_equal "kramdown", @config.fetch("markdown")
    assert_equal "rouge", @config.fetch("highlighter")
    assert_includes @config.fetch("plugins"), "jekyll-feed"
  end

  def test_research_categories_are_stable_and_ordered
    assert_equal [
      "Computer Vision",
      "Medical AI",
      "Multimodal Learning",
      "Large Language Models",
      "Paper Reading",
      "Programming",
      "Research Thoughts"
    ], @config.fetch("research_categories")
  end
end
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run:

```bash
ruby -Itest test/site_config_test.rb
```

Expected: ERROR because `_config.yml` does not exist.

- [ ] **Step 3: Add the minimal site configuration**

Create `_config.yml` with these exact public fields and build settings:

```yaml
title: "PrideLzh Blog"
description: "Research notes on AI, computer vision and medical intelligence."
url: "https://pridelzh.github.io"
baseurl: ""
author: "PrideLzh"
email: "your-email@example.com"
github_url: "https://github.com/pridelzh"
scholar_url: "https://scholar.google.com/"
lang: "en"
timezone: "Asia/Shanghai"
permalink: /notes/:year/:month/:day/:title/
markdown: kramdown
highlighter: rouge
future: false
plugins:
  - jekyll-feed
research_categories:
  - Computer Vision
  - Medical AI
  - Multimodal Learning
  - Large Language Models
  - Paper Reading
  - Programming
  - Research Thoughts
exclude:
  - docs
  - test
  - Gemfile
  - Gemfile.lock
  - vendor
```

Create `Gemfile`:

```ruby
source "https://rubygems.org"

gem "github-pages", group: :jekyll_plugins
```

- [ ] **Step 4: Run the configuration test**

Run:

```bash
ruby -Itest test/site_config_test.rb
```

Expected: 2 runs, 0 failures, 0 errors.

- [ ] **Step 5: Install and lock the Ruby dependencies**

Run:

```bash
bundle config set --local path vendor/bundle
bundle install
```

Expected: Bundler completes and creates `Gemfile.lock` without installing any Node.js dependency.

- [ ] **Step 6: Commit the configuration contract**

```bash
git add Gemfile Gemfile.lock _config.yml test/site_config_test.rb
git commit -m "build: configure Jekyll research blog"
```

---

### Task 2: Build the Document Shell and Visual System

**Files:**

- Create: `test/test_helper.rb`
- Create: `test/layout_test.rb`
- Create: `_includes/header.html`
- Create: `_includes/footer.html`
- Create: `_layouts/default.html`
- Create: `_layouts/page.html`
- Create: `assets/css/style.css`

**Interfaces:**

- Consumes: identity and URLs from `_config.yml`
- Produces: the `default` and `page` layouts, `.site-shell`, `.site-header`, `.site-main`, `.site-footer`, and responsive content primitives used by every later task

- [ ] **Step 1: Add the temporary build helper**

```ruby
# test/test_helper.rb
require "fileutils"
require "jekyll"
require "minitest/autorun"
require "tmpdir"

module SiteTestHelper
  ROOT = File.expand_path("..", __dir__)
  COPY_ENTRIES = %w[
    _config.yml _includes _layouts _posts assets
    index.md about.md archive.md categories.md 404.md
  ].freeze

  def build_site(extra_files: {}, include_project_posts: true)
    Dir.mktmpdir("pridelzh-site") do |tmp|
      source = File.join(tmp, "source")
      destination = File.join(tmp, "site")
      FileUtils.mkdir_p(source)

      COPY_ENTRIES.each do |entry|
        next if entry == "_posts" && !include_project_posts

        original = File.join(ROOT, entry)
        FileUtils.cp_r(original, File.join(source, entry)) if File.exist?(original)
      end

      extra_files.each do |relative_path, content|
        target = File.join(source, relative_path)
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, content)
      end

      config = Jekyll.configuration(
        "source" => source,
        "destination" => destination,
        "future" => true,
        "quiet" => true
      )
      Jekyll::Site.new(config).process
      yield destination
    end
  end

  def output(destination, relative_path)
    File.read(File.join(destination, relative_path))
  end
end
```

- [ ] **Step 2: Write the failing document-shell test**

```ruby
# test/layout_test.rb
require_relative "test_helper"

class LayoutTest < Minitest::Test
  include SiteTestHelper

  PROBE = <<~MARKDOWN
    ---
    layout: page
    title: "Probe Page"
    permalink: /probe/
    ---
    Probe body.
  MARKDOWN

  def test_document_shell_contains_navigation_assets_and_mathjax
    build_site(extra_files: { "probe.md" => PROBE }) do |destination|
      html = output(destination, "probe/index.html")
      assert_includes html, "PrideLzh Blog"
      %w[/ /about/ /archive/ /categories/].each do |href|
        assert_includes html, %(href="#{href}")
      end
      assert_includes html, "/assets/css/style.css"
      assert_includes html, "/feed.xml"
      assert_includes html, "mathjax@3"
      assert_includes html, "Probe body."
    end
  end

  def test_stylesheet_contains_two_column_and_mobile_rules
    css = File.read(File.join(ROOT, "assets/css/style.css"))
    assert_includes css, ".content-grid"
    assert_includes css, "grid-template-columns"
    assert_match(/@media\s*\(max-width:/, css)
    refute_includes css, "@keyframes"
  end
end
```

- [ ] **Step 3: Run the layout test and verify it fails**

Run:

```bash
bundle exec ruby -Itest test/layout_test.rb
```

Expected: FAIL because the `page` layout and stylesheet do not exist.

- [ ] **Step 4: Implement the shared shell**

Implement:

- Semantic `<header>`, `<nav>`, `<main>`, and `<footer>` landmarks
- Relative URL filters on every internal link
- Dynamic document title and meta description
- Feed discovery metadata through `{% feed_meta %}`
- MathJax 3 configuration for `$...$`, `\(...\)`, `$$...$$`, and `\[...\]`
- Wine-red links, Georgia-based prose, sans-serif metadata, thin separators
- A centered 960-pixel shell
- `.content-grid` as the desktop two-column primitive
- A mobile breakpoint at 760 pixels
- Horizontal overflow protection for code, tables, and display equations
- No animations, shadows, gradients, or web-font downloads

The page layout wraps Markdown content in:

```html
<article class="page">
  <header class="page-header">
    <h1>{{ page.title }}</h1>
  </header>
  <div class="prose">{{ content }}</div>
</article>
```

- [ ] **Step 5: Run the layout test**

Run:

```bash
bundle exec ruby -Itest test/layout_test.rb
```

Expected: 2 runs, 0 failures, 0 errors.

- [ ] **Step 6: Commit the shared presentation layer**

```bash
git add _includes _layouts/default.html _layouts/page.html assets/css/style.css test/test_helper.rb test/layout_test.rb
git commit -m "feat: add academic site shell"
```

---

### Task 3: Implement the Eight-Post Home Feed and Native Expansion

**Files:**

- Create: `test/home_test.rb`
- Create: `_layouts/home.html`
- Create: `index.md`

**Interfaces:**

- Consumes: `site.posts`, `site.research_categories`, `.content-grid`, and configuration identity fields
- Produces: eight `.post-preview` elements, zero or more `.older-post` elements inside `<details>`, `.home-sidebar`, and `.empty-state`

- [ ] **Step 1: Write failing tests for populated and empty home pages**

```ruby
# test/home_test.rb
require_relative "test_helper"

class HomeTest < Minitest::Test
  include SiteTestHelper

  def fixture_posts(count)
    (1..count).to_h do |number|
      day = format("%02d", number)
      path = "_posts/2026-07-#{day}-note-#{number}.md"
      body = <<~MARKDOWN
        ---
        layout: post
        title: "Research Note #{number}"
        date: 2026-07-#{day}
        categories:
          - Computer Vision
        tags:
          - Test
        excerpt: "Excerpt #{number}."
        ---
        Body #{number}.
      MARKDOWN
      [path, body]
    end
  end

  def test_home_shows_eight_rich_previews_and_expands_the_rest
    build_site(extra_files: fixture_posts(10), include_project_posts: false) do |destination|
      html = output(destination, "index.html")
      assert_equal 8, html.scan('class="post-preview"').size
      assert_equal 2, html.scan('class="older-post"').size
      assert_includes html, "<details"
      assert_includes html, "More posts"
      assert_includes html, "/archive/"
    end
  end

  def test_home_has_an_explicit_empty_state
    build_site(include_project_posts: false) do |destination|
      html = output(destination, "index.html")
      assert_includes html, 'class="empty-state"'
      assert_includes html, "Research notes will appear here."
    end
  end
end
```

- [ ] **Step 2: Run the home tests and verify they fail**

Run:

```bash
bundle exec ruby -Itest test/home_test.rb
```

Expected: FAIL because `index.md` and the `home` layout do not exist.

- [ ] **Step 3: Implement the home page**

Create `index.md` with `layout: home`, a description, and the approved
Computer Science student introduction.

In `_layouts/home.html`:

```liquid
{% for post in site.posts limit: 8 %}
  <article class="post-preview">
    <!-- date, linked title, category, tags, and excerpt -->
  </article>
{% endfor %}

{% if site.posts.size > 8 %}
  <details class="more-posts">
    <summary>More posts</summary>
    <ol class="older-posts">
      {% for post in site.posts offset: 8 %}
        <li class="older-post">
          <!-- compact date and linked title -->
        </li>
      {% endfor %}
    </ol>
    <a href="{{ '/archive/' | relative_url }}">View the complete archive</a>
  </details>
{% endif %}
```

Add a no-post branch with the exact text `Research notes will appear here.`.
Build the sidebar from `site.research_categories`; retrieve each category with
`site.categories[area]` and show a zero count when it is absent. Group
`site.posts` by year for the compact year archive.

- [ ] **Step 4: Run the home tests**

Run:

```bash
bundle exec ruby -Itest test/home_test.rb
```

Expected: 2 runs, 0 failures, 0 errors.

- [ ] **Step 5: Run all tests accumulated so far**

Run:

```bash
bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |file| require_relative file }'
```

Expected: all configuration, layout, and home tests pass.

- [ ] **Step 6: Commit the home page**

```bash
git add _layouts/home.html index.md test/home_test.rb
git commit -m "feat: add expandable research note feed"
```

---

### Task 4: Add Post Rendering and Knowledge-Navigation Pages

**Files:**

- Create: `test/content_pages_test.rb`
- Create: `_includes/post-meta.html`
- Create: `_layouts/post.html`
- Create: `about.md`
- Create: `archive.md`
- Create: `categories.md`
- Create: `404.md`
- Create: `_posts/2026-07-31-understanding-transformer.md`

**Interfaces:**

- Consumes: `site.posts`, `site.categories`, `site.research_categories`, config profile links, and the shared page shell
- Produces: `/about/`, `/archive/`, `/categories/`, `/404.html`, and `/notes/2026/07/31/understanding-transformer/`

- [ ] **Step 1: Write the failing content-page tests**

```ruby
# test/content_pages_test.rb
require_relative "test_helper"

class ContentPagesTest < Minitest::Test
  include SiteTestHelper

  def test_about_archive_categories_post_and_404_are_generated
    build_site do |destination|
      about = output(destination, "about/index.html")
      archive = output(destination, "archive/index.html")
      categories = output(destination, "categories/index.html")
      not_found = output(destination, "404.html")
      post = output(destination, "notes/2026/07/31/understanding-transformer/index.html")

      assert_includes about, "PrideLzh"
      assert_includes about, "Foundation Models"
      assert_includes about, "https://github.com/pridelzh"
      assert_includes archive, "2026"
      assert_includes archive, "Understanding Transformer"

      [
        "Computer Vision",
        "Medical AI",
        "Multimodal Learning",
        "Large Language Models",
        "Paper Reading",
        "Programming",
        "Research Thoughts"
      ].each { |area| assert_includes categories, area }

      assert_includes not_found, "Page not found"
      assert_includes post, 'class="post-meta"'
      assert_includes post, "Large Language Models"
      assert_includes post, "Transformer"
      assert_includes post, 'class="highlight"'
      assert_includes post, "mathjax@3"
    end
  end

  def test_generated_internal_links_resolve
    build_site do |destination|
      html_files = Dir.glob(File.join(destination, "**/*.html"))
      html_files.each do |html_file|
        File.read(html_file).scan(/href="(\/[^"#?]*)"/).flatten.each do |href|
          next if href.start_with?("/assets/")
          candidate = href.end_with?("/") ? File.join(destination, href, "index.html") : File.join(destination, href)
          assert File.exist?(candidate), "#{href} from #{html_file} does not resolve"
        end
      end
    end
  end
end
```

- [ ] **Step 2: Run the content tests and verify they fail**

Run:

```bash
bundle exec ruby -Itest test/content_pages_test.rb
```

Expected: FAIL because the secondary pages, post layout, and sample post do not
exist.

- [ ] **Step 3: Implement reusable post metadata and the post layout**

`_includes/post-meta.html` must:

- Render the date with a semantic `<time datetime="YYYY-MM-DD">`
- Render categories only when `post.categories` is non-empty
- Render tags only when `post.tags` is non-empty
- Avoid empty separators

`_layouts/post.html` must:

- Extend `default`
- Render `.post-header`, `.post-title`, `.post-meta`, and `.prose`
- End with a normal link to `/archive/`

- [ ] **Step 4: Implement About, Archive, Categories, and 404**

- `about.md`: approved profile, interests, education, and config-backed links
- `archive.md`: `group_by_exp` on `post.date | date: "%Y"` and reverse chronological entries
- `categories.md`: iterate `site.research_categories` so zero-count areas remain visible
- `404.md`: `permalink: /404.html` and links to Home, Archive, and Categories

- [ ] **Step 5: Add the sample research note**

Create `_posts/2026-07-31-understanding-transformer.md` with the exact front
matter contract, a concise explanatory note, one Python fenced-code example,
inline math `$d_k$`, and display math:

```latex
\[
\operatorname{Attention}(Q,K,V)
= \operatorname{softmax}\left(\frac{QK^\top}{\sqrt{d_k}}\right)V
\]
```

- [ ] **Step 6: Run the content-page tests**

Run:

```bash
bundle exec ruby -Itest test/content_pages_test.rb
```

Expected: 2 runs, 0 failures, 0 errors.

- [ ] **Step 7: Run the full suite**

Run:

```bash
bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |file| require_relative file }'
```

Expected: all tests pass.

- [ ] **Step 8: Commit the complete browsing system**

```bash
git add _includes/post-meta.html _layouts/post.html about.md archive.md categories.md 404.md _posts test/content_pages_test.rb
git commit -m "feat: add research archive and post system"
```

---

### Task 5: Document Authoring and GitHub Pages Deployment

**Files:**

- Create: `test/readme_test.rb`
- Create: `README.md`

**Interfaces:**

- Consumes: actual filenames, commands, front matter, config keys, remote repository, and Pages settings
- Produces: a complete operator guide for writing, previewing, replacing Hexo, deploying, and updating profile links

- [ ] **Step 1: Write the failing README contract**

```ruby
# test/readme_test.rb
require "minitest/autorun"

class ReadmeTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def setup
    @readme = File.read(File.join(ROOT, "README.md"))
  end

  def test_readme_covers_the_complete_workflow
    [
      "Create a new post",
      "_posts/YYYY-MM-DD-short-slug.md",
      "bundle exec jekyll serve",
      "Replace an old Hexo site",
      "Deploy to GitHub Pages",
      "main",
      "/ (root)",
      "https://pridelzh.github.io",
      "your-email@example.com",
      "scholar_url"
    ].each { |text| assert_includes @readme, text }
  end
end
```

- [ ] **Step 2: Run the README test and verify it fails**

Run:

```bash
ruby -Itest test/readme_test.rb
```

Expected: ERROR because `README.md` does not exist.

- [ ] **Step 3: Write the complete README**

The README must include:

1. Project purpose and stack
2. The complete repository tree and one-line responsibility for each file
3. A copyable Markdown post example
4. Filename, category, tag, code, image, and LaTeX authoring guidance
5. Ruby and Bundler local-preview commands
6. Production-build and test commands
7. Safe Hexo replacement steps that start with a backup and exact target check
8. Git commands for adding, committing, and pushing the Jekyll root
9. Pages settings: Deploy from a branch, `main`, `/ (root)`
10. Expected public URL and typical first-deployment delay
11. Exact `_config.yml` fields for replacing Email and Google Scholar values

- [ ] **Step 4: Run the README test**

Run:

```bash
ruby -Itest test/readme_test.rb
```

Expected: 1 run, 0 failures, 0 errors.

- [ ] **Step 5: Commit the operator documentation**

```bash
git add README.md test/readme_test.rb
git commit -m "docs: add writing and deployment guide"
```

---

### Task 6: Perform Production and Visual Verification

**Files:**

- Modify only if verification exposes a defect in an already-created file

**Interfaces:**

- Consumes: the complete repository
- Produces: fresh evidence that tests, the production build, internal links, desktop layout, and mobile layout satisfy the design

- [ ] **Step 1: Run the full automated suite**

Run:

```bash
bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |file| require_relative file }'
```

Expected: 0 failures and 0 errors.

- [ ] **Step 2: Run a clean production build**

Run:

```bash
bundle exec jekyll clean
JEKYLL_ENV=production bundle exec jekyll build --trace
```

Expected: exit code 0 and generated Home, About, Archive, Categories, 404,
sample post, stylesheet, and `feed.xml`.

- [ ] **Step 3: Verify generated outputs explicitly**

Run:

```bash
test -f _site/index.html
test -f _site/about/index.html
test -f _site/archive/index.html
test -f _site/categories/index.html
test -f _site/404.html
test -f _site/notes/2026/07/31/understanding-transformer/index.html
test -f _site/assets/css/style.css
test -f _site/feed.xml
```

Expected: every command exits 0.

- [ ] **Step 4: Serve the production output locally**

Run:

```bash
bundle exec jekyll serve --no-watch
```

Expected: the site responds at `http://127.0.0.1:4000/`.

Keep this command running in its dedicated terminal until the visual inspection
is complete.

- [ ] **Step 5: Inspect desktop and mobile renders**

Capture and inspect:

- Home at 1440 × 1000
- Home at 390 × 844
- Sample post at 1440 × 1000
- Sample post at 390 × 844

Check:

- Desktop home has a wide article column and narrow sidebar
- Mobile home is single-column with no horizontal page overflow
- Navigation wraps without overlap
- The default home shows no more than eight rich previews
- `<details>` opens and reveals compact older posts in the ten-post test build
- Code scrolls inside its block
- Formula source has MathJax configuration available
- Dates, categories, tags, and footer remain legible

- [ ] **Step 6: Stop the local server and inspect repository state**

Run:

```bash
git diff --check
git status --short
```

First stop the dedicated Jekyll terminal with `Ctrl+C`. Expected: no whitespace
errors; only intentional implementation changes are present.

- [ ] **Step 7: Commit any verification-only fixes**

If Step 5 revealed and Step 6 confirmed a defect, first add a failing automated
test that reproduces it, then implement the smallest fix, rerun Steps 1–5, and
commit:

```bash
git add --update
git commit -m "fix: correct verified site rendering issue"
```

If no defect exists, do not create an empty commit.

---

## Final Requirement Check

Before handing off:

- [ ] All requested pages exist and build
- [ ] All seven research areas remain visible
- [ ] Home defaults to eight rich previews
- [ ] Older posts expand without custom JavaScript
- [ ] Sample post demonstrates metadata, Rouge, and MathJax
- [ ] README explains every file and all four GitHub Pages deployment steps
- [ ] No Node.js manifest, application framework, database, or backend exists
- [ ] Full test suite passes
- [ ] Production Jekyll build passes
- [ ] Desktop and mobile renders have been inspected
- [ ] Git status contains no accidental files
