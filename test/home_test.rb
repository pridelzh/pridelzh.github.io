require_relative "test_helper"
require "nokogiri"

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
      document = Nokogiri::HTML(output(destination, "index.html"))
      details = document.at_css("details.more-posts") or flunk "missing more-posts details"

      assert_equal 8, document.css(".post-preview").size
      assert_equal "More posts", details.at_xpath("./summary")&.text
      assert_equal 2, details.css(".older-post").size
      assert_equal details.css(".older-post").size, document.css(".older-post").size
      assert document.at_css('.home-feed a[href="/archive/"]')
      assert_nil details.at_css('a[href="/archive/"]')
    end
  end

  def test_home_has_an_explicit_empty_state
    build_site(include_project_posts: false) do |destination|
      html = output(destination, "index.html")
      assert_includes html, 'class="empty-state"'
      assert_includes html, "Research notes will appear here."
    end
  end

  def test_home_with_one_post_still_links_to_the_complete_archive
    build_site(extra_files: fixture_posts(1), include_project_posts: false) do |destination|
      document = Nokogiri::HTML(output(destination, "index.html"))

      assert_nil document.at_css("details.more-posts")
      archive_link = document.at_css('.home-feed a[href="/archive/"]') or
        flunk "missing complete archive link"
      assert_equal "View the complete archive", archive_link.text.strip
    end
  end
end
