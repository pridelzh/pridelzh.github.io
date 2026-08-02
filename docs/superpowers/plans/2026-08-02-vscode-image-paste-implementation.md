# Portable VS Code Image Paste Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `Ctrl+V` in a Jekyll post save images into a public, post-specific repository directory and render them correctly in both VS Code preview and GitHub Pages.

**Architecture:** A committed VS Code folder setting maps pasted post images into `assets/images/<post-basename>/` without overwriting existing files. VS Code inserts a source-relative `../assets/...` path, so the post layout narrowly normalizes that generated HTML prefix through Jekyll's `relative_url` filter; tests protect the mapping, baseurl behavior, migrated asset, and documentation.

**Tech Stack:** VS Code Markdown folder settings, Jekyll, Liquid, Kramdown, Ruby, Minitest, Nokogiri, GitHub Pages

## Global Constraints

- Keep the workflow in the repository so it survives cloning onto another computer.
- Require no VS Code extension, Node.js, React, Vue, database, backend service, or unsupported Jekyll plugin.
- Preserve the permalink `/notes/:year/:month/:day/:title/` and all existing public URLs.
- Store pasted images at `assets/images/<post-file-basename>/<image-file-name>`.
- Use `nameIncrementally` so repeated pasted filenames never silently overwrite an existing image.
- Normalize only post-content image sources beginning with `../assets/`; leave other URLs and site elements unchanged.
- Generate the public prefix with Liquid's `relative_url` filter so both an empty `baseurl` and `/research` work.
- Keep the manual Liquid image form as the editor-independent fallback.
- Follow test-driven development: observe each new contract fail before adding its implementation.

## File Structure

- Create `.vscode/settings.json`: portable VS Code image destination and collision behavior.
- Create `test/image_authoring_test.rb`: contracts for workspace settings, asset placement, and the migrated real post.
- Modify `_layouts/post.html`: post-only conversion of the source-relative asset prefix to the public Jekyll prefix.
- Modify `test/content_pages_test.rb`: integration coverage for generated image URLs under two base URLs.
- Move `_posts/image.png` to `assets/images/2026-08-02-record-algorithm-exercise/image.png`: publish the existing screenshot as a static asset.
- Modify `_posts/2026-08-02-record-algorithm-exercise.md`: adopt the generated relative-link convention and descriptive alt text.
- Modify `README.md`: document direct paste, portability, generated paths, and the manual fallback.
- Modify `test/readme_test.rb`: protect the documented direct-paste workflow.

---

### Task 1: Portable VS Code Folder Settings

**Files:**
- Create: `.vscode/settings.json`
- Create: `test/image_authoring_test.rb`

**Interfaces:**
- Consumes: VS Code's built-in `markdown.copyFiles.destination` and `markdown.copyFiles.overwriteBehavior` settings.
- Produces: a mapping from `/_posts/**/*` to `/assets/images/${documentBaseName}/${fileName}` with collision-safe naming; later tasks rely on the resulting `../assets/images/...` Markdown link shape.

- [ ] **Step 1: Write the failing workspace-settings contract**

Create `test/image_authoring_test.rb`:

```ruby
require "json"
require "minitest/autorun"

class ImageAuthoringTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)

  def test_vscode_paste_destination_is_portable_and_collision_safe
    settings_path = File.join(ROOT, ".vscode", "settings.json")
    assert File.file?(settings_path), "missing committed VS Code folder settings"

    settings = JSON.parse(File.read(settings_path))
    assert_equal(
      "/assets/images/${documentBaseName}/${fileName}",
      settings.fetch("markdown.copyFiles.destination").fetch("/_posts/**/*")
    )
    assert_equal "nameIncrementally", settings.fetch("markdown.copyFiles.overwriteBehavior")
  end
end
```

- [ ] **Step 2: Run the focused test and verify the contract fails**

Run:

```bash
bundle exec ruby -Itest test/image_authoring_test.rb
```

Expected: FAIL with `missing committed VS Code folder settings` because `.vscode/settings.json` does not exist.

- [ ] **Step 3: Add the minimal repository-level VS Code configuration**

Create `.vscode/settings.json`:

```json
{
  "markdown.copyFiles.destination": {
    "/_posts/**/*": "/assets/images/${documentBaseName}/${fileName}"
  },
  "markdown.copyFiles.overwriteBehavior": "nameIncrementally"
}
```

- [ ] **Step 4: Run the focused test and verify it passes**

Run:

```bash
bundle exec ruby -Itest test/image_authoring_test.rb
```

Expected: 1 run, 3 assertions, 0 failures, 0 errors.

- [ ] **Step 5: Commit the portable editor contract**

```bash
git add .vscode/settings.json test/image_authoring_test.rb
git commit -m "feat: configure portable post image pasting"
```

---

### Task 2: Baseurl-Safe Post Image Rendering

**Files:**
- Modify: `test/content_pages_test.rb:40-62`
- Modify: `_layouts/post.html:10-12`

**Interfaces:**
- Consumes: generated post HTML containing `src="../assets/..."` and Jekyll's `relative_url` Liquid filter.
- Produces: `src="/assets/..."` for an empty base URL and `src="/research/assets/..."` for `baseurl: /research`.

- [ ] **Step 1: Write the failing post-rendering integration test**

Add this test before `test_sample_post_preserves_mathjax_display_delimiters` in `test/content_pages_test.rb`:

```ruby
  def test_vscode_pasted_image_resolves_for_root_and_project_baseurls
    post_source = <<~MARKDOWN
      ---
      layout: post
      title: "Paste Probe"
      date: 2026-08-02
      categories:
        - Programming
      ---

      ![Cycle detection diagram](../assets/images/2026-08-02-paste-probe/image.png)
    MARKDOWN

    ["", "/research"].each do |baseurl|
      build_site(
        extra_files: {
          "_posts/2026-08-02-paste-probe.md" => post_source,
          "assets/images/2026-08-02-paste-probe/image.png" => "fixture image"
        },
        include_project_posts: false,
        config_overrides: { "baseurl" => baseurl }
      ) do |destination|
        post = output(destination, "notes/2026/08/02/paste-probe/index.html")
        expected_src = "#{baseurl}/assets/images/2026-08-02-paste-probe/image.png"

        assert_includes post, %(src="#{expected_src}")
        assert File.file?(File.join(destination, "assets/images/2026-08-02-paste-probe/image.png"))
      end
    end
  end
```

- [ ] **Step 2: Run the focused test and verify the unnormalized URL fails**

Run:

```bash
bundle exec ruby -Itest test/content_pages_test.rb --name test_vscode_pasted_image_resolves_for_root_and_project_baseurls
```

Expected: FAIL because the generated HTML still contains `src="../assets/images/..."`.

- [ ] **Step 3: Normalize only the VS Code post-image prefix**

Replace `{{ content }}` in `_layouts/post.html` with:

```liquid
    {% assign local_asset_prefix = 'src="../assets/' %}
    {% capture public_asset_prefix %}src="{{ '/assets/' | relative_url }}{% endcapture %}
    {{ content | replace: local_asset_prefix, public_asset_prefix }}
```

This operates on Kramdown's generated post HTML, adds no plugin, and leaves any image source not starting with the exact local prefix unchanged.

- [ ] **Step 4: Run the focused integration test and verify both URL modes pass**

Run:

```bash
bundle exec ruby -Itest test/content_pages_test.rb --name test_vscode_pasted_image_resolves_for_root_and_project_baseurls
```

Expected: 1 run, 6 assertions, 0 failures, 0 errors.

- [ ] **Step 5: Run content and layout regressions**

Run:

```bash
bundle exec ruby -Itest test/content_pages_test.rb
bundle exec ruby -Itest test/layout_test.rb
```

Expected: both commands finish with 0 failures and 0 errors.

- [ ] **Step 6: Commit the rendering behavior**

```bash
git add _layouts/post.html test/content_pages_test.rb
git commit -m "fix: render pasted post images at public URLs"
```

---

### Task 3: Migrate the Existing 2026-08-02 Image

**Files:**
- Modify: `test/image_authoring_test.rb`
- Move: `_posts/image.png` to `assets/images/2026-08-02-record-algorithm-exercise/image.png`
- Modify: `_posts/2026-08-02-record-algorithm-exercise.md:17-18`

**Interfaces:**
- Consumes: the destination and relative-link convention introduced in Tasks 1 and 2.
- Produces: a tracked public asset and a real post whose preview and deployed image references both resolve.

- [ ] **Step 1: Add failing repository asset-placement tests**

Add these constants and tests inside `ImageAuthoringTest`:

```ruby
  POST_FILE = "2026-08-02-record-algorithm-exercise.md"
  IMAGE_RELATIVE_PATH = "assets/images/2026-08-02-record-algorithm-exercise/image.png"
  POST_IMAGE_MARKDOWN =
    "![Floyd's cycle detection with fast and slow pointers](../#{IMAGE_RELATIVE_PATH})"

  def test_existing_algorithm_post_uses_the_public_asset_convention
    post = File.read(File.join(ROOT, "_posts", POST_FILE))

    assert_includes post, POST_IMAGE_MARKDOWN
    assert File.file?(File.join(ROOT, IMAGE_RELATIVE_PATH)), "missing migrated post image"
  end

  def test_posts_directory_contains_only_markdown_sources
    non_markdown_files = Dir.glob(File.join(ROOT, "_posts", "**", "*"))
      .select { |path| File.file?(path) && File.extname(path) != ".md" }
      .map { |path| path.delete_prefix("#{ROOT}/") }

    assert_empty non_markdown_files, "non-Markdown files in _posts: #{non_markdown_files.join(', ')}"
  end
```

- [ ] **Step 2: Run the focused tests and verify both placement contracts fail**

Run:

```bash
bundle exec ruby -Itest test/image_authoring_test.rb
```

Expected: 2 failures showing the missing migrated asset/reference and `_posts/image.png` as an invalid non-Markdown file.

- [ ] **Step 3: Move the binary image without rewriting it**

Run:

```bash
mkdir -p assets/images/2026-08-02-record-algorithm-exercise
git mv _posts/image.png assets/images/2026-08-02-record-algorithm-exercise/image.png
```

- [ ] **Step 4: Update the post reference and alt text**

Replace the current image line in `_posts/2026-08-02-record-algorithm-exercise.md` with:

```markdown
   ![Floyd's cycle detection with fast and slow pointers](../assets/images/2026-08-02-record-algorithm-exercise/image.png)
```

Also remove the trailing space after `**Image example:**` on the preceding line.

- [ ] **Step 5: Run the asset-placement tests and verify they pass**

Run:

```bash
bundle exec ruby -Itest test/image_authoring_test.rb
```

Expected: 3 runs, 8 assertions, 0 failures, 0 errors.

- [ ] **Step 6: Build and inspect the real post contract**

Run:

```bash
bundle exec jekyll build --trace
grep -F 'src="/assets/images/2026-08-02-record-algorithm-exercise/image.png"' _site/notes/2026/08/02/record-algorithm-exercise/index.html
test -f _site/assets/images/2026-08-02-record-algorithm-exercise/image.png
```

Expected: grep prints the generated `<img>` line and the file check exits successfully.

- [ ] **Step 7: Commit the migrated image and post**

```bash
git add test/image_authoring_test.rb _posts/2026-08-02-record-algorithm-exercise.md assets/images/2026-08-02-record-algorithm-exercise/image.png
git commit -m "fix: publish algorithm post image from assets"
```

---

### Task 4: Document the Direct-Paste Workflow

**Files:**
- Modify: `test/readme_test.rb:12-24`
- Modify: `README.md:13-98`
- Modify: `README.md:100-156`

**Interfaces:**
- Consumes: the exact editor mapping and rendering convention from Tasks 1 through 3.
- Produces: a copyable, computer-independent workflow plus the existing manual Liquid fallback.

- [ ] **Step 1: Extend the README workflow contract**

Add these strings to the array in `test_readme_covers_the_complete_workflow`:

```ruby
      "Ctrl+V",
      ".vscode/settings.json",
      "assets/images/<post-file-basename>/",
      "Open the repository root",
      "editor-independent fallback",
```

- [ ] **Step 2: Run the README contract and verify it fails**

Run:

```bash
bundle exec ruby -Itest test/readme_test.rb --name test_readme_covers_the_complete_workflow
```

Expected: FAIL because the direct-paste phrases are not yet documented.

- [ ] **Step 3: Update the repository structure and responsibilities**

In the README tree, add:

```text
├── .vscode/
│   └── settings.json
```

Under `assets/`, show both `css/` and the post-specific image directory. Add responsibility entries explaining that `.vscode/settings.json` controls portable paste destinations and that `assets/images/` contains committed public post media. Add the new design and implementation-plan filenames under `docs/superpowers/`.

- [ ] **Step 4: Add the direct-paste instructions and fallback**

Insert this subsection before `Authoring rules:`:

````markdown
### Paste an image directly from VS Code

Open the repository root as the VS Code workspace, edit a file under `_posts/`,
and press `Ctrl+V`. The committed `.vscode/settings.json` automatically stores
the image in `assets/images/<post-file-basename>/` and inserts a link that works
in the VS Code preview. Jekyll converts that source-relative link to the public
GitHub Pages asset URL when it builds the post.

Commit both the Markdown file and its new image directory. Because the setting
belongs to this repository, the same behavior applies after cloning it onto a
different computer; no image-paste extension is required.

As an editor-independent fallback, place the image under `assets/images/`
manually and use Liquid explicitly:

```markdown
![Descriptive alt text]({{ '/assets/images/example.png' | relative_url }})
```
````

Change the image bullet under `Authoring rules` to require descriptive alt text, committing the image with the post, and keeping manually managed images under `assets/images/`; remove the implication that the manual Liquid form is the primary VS Code workflow.

- [ ] **Step 5: Run the complete README tests and verify they pass**

Run:

```bash
bundle exec ruby -Itest test/readme_test.rb
```

Expected: all README tests finish with 0 failures and 0 errors, including the existing copyable-post image and LaTeX checks.

- [ ] **Step 6: Commit the author documentation**

```bash
git add README.md test/readme_test.rb
git commit -m "docs: explain portable image paste workflow"
```

---

### Task 5: Full Regression and Production Verification

**Files:**
- Verify: all tracked source files changed in Tasks 1 through 4

**Interfaces:**
- Consumes: the completed portable-paste workflow.
- Produces: evidence that the tree is clean, tests pass, production builds, and every generated local image source resolves to a built file.

- [ ] **Step 1: Check formatting and repository state**

Run:

```bash
git diff --check
git status --short
```

Expected: `git diff --check` emits no output and `git status --short` is empty because the plan and each completed task have been committed.

- [ ] **Step 2: Run the full Minitest suite**

Run:

```bash
bundle exec ruby -Itest -e 'Dir["test/**/*_test.rb"].sort.each { |file| require_relative file }'
```

Expected: all tests finish with 0 failures and 0 errors.

- [ ] **Step 3: Run a clean production build**

Run:

```bash
bundle exec jekyll clean
JEKYLL_ENV=production bundle exec jekyll build --trace
```

Expected: Jekyll exits successfully and writes `_site/` without build errors.

- [ ] **Step 4: Verify every generated local image points to a built file**

Run:

```bash
bundle exec ruby -rnokogiri -e '
root = File.expand_path("_site")
errors = Dir.glob(File.join(root, "**", "*.html")).flat_map do |html|
  Nokogiri::HTML(File.read(html)).css("img[src]").filter_map do |image|
    src = image["src"]
    next if src.match?(%r{\A(?:https?:)?//|\Adata:})
    path = src.sub(%r{\A/}, "").split(/[?#]/, 2).first
    "#{html.delete_prefix(root + "/")}: #{src}" unless File.file?(File.join(root, path))
  end
end
abort(errors.join("\n")) unless errors.empty?
puts "all generated local images resolve"
'
```

Expected: prints `all generated local images resolve` and exits successfully.

- [ ] **Step 5: Confirm the final history and clean tree**

Run:

```bash
git log --oneline --decorate -7
git status --short
```

Expected: the task, plan, and design commits are visible, and `git status --short` is empty.
