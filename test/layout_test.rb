require_relative "test_helper"
require "nokogiri"

class LayoutTest < Minitest::Test
  include SiteTestHelper

  MATHJAX_URL = "https://cdn.jsdelivr.net/npm/mathjax@3.2.2/es5/tex-svg.js"
  MATHJAX_SRI = "sha384-KKWa9jJ1MZvssLeOoXG6FiOAZfAgmzsIIfw8BXwI9+kYm0lPCbC6yTQPBC00F1/L"

  PROBE = <<~MARKDOWN
    ---
    layout: page
    title: "Probe Page"
    description: "Probe description."
    permalink: /probe/
    ---
    Probe body. [About]({{ '/about/' | relative_url }}).
  MARKDOWN

  def test_document_shell_honors_non_empty_baseurl
    build_site(
      extra_files: { "probe.md" => PROBE },
      config_overrides: { "baseurl" => "/research" }
    ) do |destination|
      document = Nokogiri::HTML(output(destination, "probe/index.html"))

      assert_equal "en", document.at_css("html")["lang"]
      assert_equal "Probe Page · PrideLzh Blog", document.at_css("title").text
      assert_equal "Probe description.", document.at_css('meta[name="description"]')["content"]
      %w[header nav main footer].each { |landmark| assert document.at_css(landmark), "missing #{landmark}" }

      hrefs = document.css("[href]").map { |node| node["href"] }
      %w[
        /research/
        /research/about/
        /research/archive/
        /research/categories/
        /research/assets/css/style.css
        /research/feed.xml
      ].each { |href| assert_includes hrefs, href }
    end
  end

  def test_document_shell_contains_navigation_assets_and_mathjax
    build_site(extra_files: { "probe.md" => PROBE }) do |destination|
      html = output(destination, "probe/index.html")
      document = Nokogiri::HTML(html)
      assert_includes html, "PrideLzh Blog"
      %w[/ /about/ /archive/ /categories/].each do |href|
        assert_includes html, %(href="#{href}")
      end
      assert_includes html, "/assets/css/style.css"
      assert_includes html, "/feed.xml"

      mathjax = document.at_css(%(script[src="#{MATHJAX_URL}"])) or
        flunk "missing pinned MathJax SVG entrypoint"
      assert_equal MATHJAX_SRI, mathjax["integrity"]
      assert_equal "anonymous", mathjax["crossorigin"]
      assert_equal "no-referrer", mathjax["referrerpolicy"]
      refute_nil mathjax.attribute("defer")
      assert_includes html, "Probe body."
    end
  end

  def test_stylesheet_contains_two_column_and_mobile_rules
    css = File.read(File.join(ROOT, "assets/css/style.css"))
    assert_includes css, ".content-grid"
    assert_includes css, "grid-template-columns"
    assert_match(/@media\s*\(max-width:/, css)
    refute_includes css, "@keyframes"
  end
end
