require_relative "test_helper"

class LayoutTest < Minitest::Test
  include SiteTestHelper

  PROBE = <<~MARKDOWN
    ---
    layout: page
    title: "Probe Page"
    permalink: /probe/
    ---
    Probe body.
  MARKDOWN

  def test_document_shell_contains_navigation_assets_and_mathjax
    build_site(extra_files: { "probe.md" => PROBE }) do |destination|
      html = output(destination, "probe/index.html")
      assert_includes html, "PrideLzh Blog"
      %w[/ /about/ /archive/ /categories/].each do |href|
        assert_includes html, %(href="#{href}")
      end
      assert_includes html, "/assets/css/style.css"
      assert_includes html, "/feed.xml"
      assert_includes html, "mathjax@3"
      assert_includes html, "tex-svg.js"
      refute_includes html, "tex-chtml.js"
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
