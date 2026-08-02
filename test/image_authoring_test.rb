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
