require "json"
require "minitest/autorun"

class ImageAuthoringTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  POST_FILE = "2026-08-02-record-algorithm-exercise.md"
  IMAGE_RELATIVE_PATH = "assets/images/2026-08-02-record-algorithm-exercise/image.png"
  POST_IMAGE_MARKDOWN =
    "![Floyd's cycle detection with fast and slow pointers](../#{IMAGE_RELATIVE_PATH})"

  def test_vscode_paste_destination_is_portable_and_collision_safe
    settings_path = File.join(ROOT, ".vscode", "settings.json")
    assert File.file?(settings_path), "missing committed VS Code folder settings"

    settings = JSON.parse(File.read(settings_path))
    destinations = settings.fetch("markdown.copyFiles.destination")
    assert_equal ["/_posts/*"], destinations.keys
    assert_equal(
      "/assets/images/${documentBaseName}/${fileName}",
      destinations["/_posts/*"]
    )
    refute destinations.key?("/_posts/**/*"), "recursive post mapping is not supported"
    assert_equal "nameIncrementally", settings.fetch("markdown.copyFiles.overwriteBehavior")
  end

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
end
