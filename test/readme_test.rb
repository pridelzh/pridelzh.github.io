require_relative "test_helper"

class ReadmeTest < Minitest::Test
  include SiteTestHelper

  ROOT = File.expand_path("..", __dir__)

  def setup
    @readme = File.read(File.join(ROOT, "README.md"))
  end

  def test_readme_covers_the_complete_workflow
    [
      "Create a new post",
      "_posts/YYYY-MM-DD-short-slug.md",
      "Ctrl+V",
      ".vscode/settings.json",
      "assets/images/<post-file-basename>/",
      "Open the repository root",
      "editor-independent fallback",
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

  def test_copyable_post_example_preserves_display_math_delimiters
    build_site(
      extra_files: { "_posts/2026-08-01-readme-example.md" => copyable_post_example },
      include_project_posts: false
    ) do |destination|
      post = output(destination, "notes/2026/08/01/readme-example/index.html")

      assert_match(/\\\[\s*\\operatorname\{ECE\}.*?\\\]/m, post)
      refute_match(/<p>\[\s*\\operatorname\{ECE\}/m, post)
    end
  end

  def test_copyable_post_example_prefixes_its_image_with_baseurl
    build_site(
      extra_files: { "_posts/2026-08-01-readme-example.md" => copyable_post_example },
      include_project_posts: false,
      config_overrides: { "baseurl" => "/research" }
    ) do |destination|
      post = output(destination, "notes/2026/08/01/readme-example/index.html")

      assert_includes post, 'src="/research/assets/images/reliability-diagram.png"'
    end
  end

  private

  def copyable_post_example
    @readme.match(/````markdown\n(?<post>.*?)\n````/m)[:post]
  end
end
