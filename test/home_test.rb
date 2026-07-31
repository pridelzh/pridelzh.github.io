require_relative "test_helper"

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
      html = output(destination, "index.html")
      assert_equal 8, html.scan('class="post-preview"').size
      assert_equal 2, html.scan('class="older-post"').size
      assert_includes html, "<details"
      assert_includes html, "More posts"
      assert_includes html, "/archive/"
    end
  end

  def test_home_has_an_explicit_empty_state
    build_site(include_project_posts: false) do |destination|
      html = output(destination, "index.html")
      assert_includes html, 'class="empty-state"'
      assert_includes html, "Research notes will appear here."
    end
  end
end
