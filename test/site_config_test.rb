require "minitest/autorun"
require "date"
require "uri"
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

  def test_author_name_is_exact
    assert_equal "PrideLzh", @config.fetch("author")
  end

  def test_email_has_an_address_shape
    email = @config.fetch("email")

    refute_empty email
    assert_match URI::MailTo::EMAIL_REGEXP, email
  end

  def test_scholar_url_is_non_empty_https
    raw_scholar_url = @config.fetch("scholar_url")
    scholar_url = URI.parse(raw_scholar_url)

    refute_empty raw_scholar_url
    assert_equal "https", scholar_url.scheme
    refute_empty scholar_url.host
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
