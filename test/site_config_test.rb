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
