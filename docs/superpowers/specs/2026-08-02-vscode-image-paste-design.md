# VS Code Image Paste Workflow Design

Date: 2026-08-02
Status: Approved for implementation

## Purpose

Make image authoring portable and almost invisible: while editing a post under
`_posts/`, the author pastes an image with `Ctrl+V`; VS Code stores the file in
the repository's public image directory, the local Markdown preview works, and
the generated GitHub Pages post uses a valid URL. The workflow must travel with
the repository and must not require a VS Code extension, Node.js, or a custom
Jekyll plugin.

## Why a Small URL Normalization Is Necessary

VS Code creates pasted-image links relative to the Markdown source file. A post
source lives in `_posts/`, but Jekyll publishes it at a permalink such as
`/notes/2026/08/02/record-algorithm-exercise/`. A source-relative link therefore
has different meanings in VS Code and in the generated page.

For example, if VS Code copies an image to
`assets/images/2026-08-02-record-algorithm-exercise/image.png`, it inserts this
source-relative link:

```markdown
![Description](../assets/images/2026-08-02-record-algorithm-exercise/image.png)
```

That path works in VS Code, but a browser would resolve it relative to the
post's permalink. The post layout must normalize this narrowly defined source
prefix to the site's public asset prefix during the Jekyll build.

## Authoring Flow

1. Open the cloned repository itself as the VS Code workspace.
2. Create or edit a Markdown file below `_posts/`.
3. Paste an image with `Ctrl+V`.
4. VS Code copies it to
   `assets/images/<post-file-basename>/<original-image-name>`.
5. VS Code inserts a relative Markdown image reference that also works in its
   local Markdown preview.
6. Jekyll changes only the generated HTML image prefix from `../assets/` to
   `{{ '/assets/' | relative_url }}`, preserving `baseurl` compatibility.
7. The author commits the post and its image together and pushes normally.

## Repository Changes

### Workspace Settings

Add a committed `.vscode/settings.json` containing a
`markdown.copyFiles.destination` rule scoped to `/_posts/**/*`. A leading slash
in the destination anchors the copied image under the workspace root:

```json
{
  "markdown.copyFiles.destination": {
    "/_posts/**/*": "/assets/images/${documentBaseName}/${fileName}"
  },
  "markdown.copyFiles.overwriteBehavior": "nameIncrementally"
}
```

`nameIncrementally` prevents a later paste from silently replacing an existing
image. Posts elsewhere and non-Markdown files keep VS Code's default behavior.

### Post Rendering

Update `_layouts/post.html` to replace only HTML image sources beginning with
`../assets/`. The replacement prefix is generated with Liquid's `relative_url`
filter so the site remains valid both at the user-site root and under a future
non-empty `baseurl`.

Already-correct absolute URLs, remote images, data URLs, and manual Liquid image
references remain unchanged. The normalization is limited to post content and
does not affect navigation, stylesheets, scripts, or normal links.

### Existing Post Migration

Move `_posts/image.png` to
`assets/images/2026-08-02-record-algorithm-exercise/image.png` and change the
post's image reference to the same relative form VS Code will generate. Replace
the placeholder alt text with a descriptive phrase.

### Documentation

Update `README.md` so direct `Ctrl+V` is the primary image workflow. Retain the
manual `assets/images/` plus `relative_url` form as an editor-independent
fallback.

## Compatibility and Portability

- The behavior is stored in Git, not in user-level VS Code settings.
- A new computer needs only VS Code and a clone of the repository; no image
  paste extension is required.
- The repository must be opened at its own root for folder settings and the
  workspace-root destination to apply.
- Other editors can still use the documented manual image syntax.
- No unsupported Jekyll plugin is introduced, so GitHub Pages can build the
  site normally.

## Validation

Automated tests will verify that:

1. `.vscode/settings.json` is valid JSON and contains the expected portable
   destination and non-overwriting behavior.
2. A fixture post using the VS Code-generated `../assets/...` source is built
   with a correct `/assets/...` image URL.
3. The same fixture builds with a non-empty `baseurl` and produces
   `/research/assets/...`.
4. The referenced image is copied into the generated site.
5. The current 2026-08-02 post references the migrated asset and no image file
   remains directly under `_posts/`.
6. The complete existing test suite and a production Jekyll build still pass.

## Failure Behavior

- Duplicate pasted filenames receive `-1`, `-2`, and similar suffixes instead
  of overwriting earlier images.
- If VS Code folder settings are not active, the existing automated checks can
  detect images accidentally committed directly under `_posts/`.
- If a post intentionally uses another image location, its URL is unchanged
  unless its generated HTML source starts with the explicit `../assets/`
  convention.

## Acceptance Criteria

- Pasting into a post requires no manual file move or link rewrite.
- VS Code preview and the deployed GitHub Pages post both display the image.
- The workflow survives cloning the repository onto another computer.
- Existing URLs and supported GitHub Pages behavior remain unchanged.
