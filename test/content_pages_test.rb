require_relative "test_helper"

class ContentPagesTest < Minitest::Test
  include SiteTestHelper

  def test_about_archive_categories_post_and_404_are_generated
    build_site(extra_files: { "_data/moments.yml" => "moments: []\n" }) do |destination|
      about = output(destination, "about/index.html")
      archive = output(destination, "archive/index.html")
      categories = output(destination, "categories/index.html")
      moments = output(destination, "moments/index.html")
      not_found = output(destination, "404.html")
      post = output(destination, "notes/2026/07/31/understanding-transformer/index.html")

      assert_includes about, "PrideLzh"
      assert_includes about, "Foundation Models"
      assert_includes about, "https://github.com/pridelizihao"
      assert_includes archive, "2026"
      assert_includes archive, "Understanding Transformer"
      assert_includes moments, "Moments"
      assert_includes moments, "No moments yet"
      refute_includes archive, "No moments yet"
      refute_includes categories, "No moments yet"

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

  def test_moments_render_markdown_and_remain_out_of_post_indexes
    moments_source = <<~YAML
      moments:
        - date: 2026-11-15 20:00:00 +0800
          content: >-
            今天完成了一个小功能，也留了一点时间散步。![记录](assets/images/moments/legacy.jpg)
    YAML

    build_site(
      extra_files: { "_data/moments.yml" => moments_source },
      include_project_posts: false
    ) do |destination|
      moments = output(destination, "moments/index.html")
      archive = output(destination, "archive/index.html")
      categories = output(destination, "categories/index.html")

      assert_includes moments, "今天完成了一个小功能"
      assert_includes moments, "2026-11-15T20:00:00+08:00"
      assert_includes moments, 'src="/assets/images/moments/legacy.jpg"'
      refute_includes archive, "今天完成了一个小功能"
      refute_includes categories, "今天完成了一个小功能"
    end
  end

  def test_moments_render_multiple_markdown_images
    moments_source = <<~YAML
      moments:
        - date: 2026-11-15 20:00:00 +0800
          content: |
            今晚的记录

            ![第一张图](assets/images/moments/one.jpg)
            ![第二张图](../assets/images/moments/two.jpg)
    YAML

    build_site(extra_files: { "_data/moments.yml" => moments_source }, include_project_posts: false) do |destination|
      moments = output(destination, "moments/index.html")

      assert_equal 2, moments.scan('<img').size
      assert_includes moments, 'src="/assets/images/moments/one.jpg"'
      assert_includes moments, 'src="/assets/images/moments/two.jpg"'
      assert_includes moments, 'alt="第一张图"'
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

  def test_vscode_pasted_image_resolves_for_root_and_project_baseurls
    post_source = <<~MARKDOWN
      ---
      layout: post
      title: "Paste Probe"
      date: 2026-08-02
      categories:
        - Programming
      ---

      ![Cycle detection diagram](../assets/images/2026-08-02-paste-probe/image.png)

      <script src="../assets/scripts/not-an-image.js"></script>
    MARKDOWN

    ["", "/research"].each do |baseurl|
      build_site(
        extra_files: {
          "_posts/2026-08-02-paste-probe.md" => post_source,
          "assets/images/2026-08-02-paste-probe/image.png" => "fixture image"
        },
        include_project_posts: false,
        config_overrides: { "baseurl" => baseurl }
      ) do |destination|
        post = output(destination, "notes/2026/08/02/paste-probe/index.html")
        expected_src = "#{baseurl}/assets/images/2026-08-02-paste-probe/image.png"

        assert_includes post, %(src="#{expected_src}")
        assert File.file?(File.join(destination, "assets/images/2026-08-02-paste-probe/image.png"))
        assert_includes post, 'src="../assets/scripts/not-an-image.js"'
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
