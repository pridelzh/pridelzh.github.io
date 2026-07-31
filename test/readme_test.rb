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
