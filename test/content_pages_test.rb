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
      assert_includes about, "https://github.com/pridelizihao"
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

  def test_sample_post_preserves_mathjax_display_delimiters
    build_site do |destination|
      post = output(destination, "notes/2026/07/31/understanding-transformer/index.html")

      assert_match(
        /\\\[\s*\\operatorname\{Attention\}\(Q,K,V\).*?\\\]/m,
        post
      )
    end
  end
end
