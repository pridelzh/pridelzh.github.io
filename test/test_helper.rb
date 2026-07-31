require "fileutils"
require "jekyll"
require "minitest/autorun"
require "tmpdir"

module SiteTestHelper
  ROOT = File.expand_path("..", __dir__)
  COPY_ENTRIES = %w[
    _config.yml _includes _layouts _posts assets
    index.md about.md archive.md categories.md 404.md
  ].freeze

  def build_site(extra_files: {}, include_project_posts: true)
    Dir.mktmpdir("pridelzh-site") do |tmp|
      source = File.join(tmp, "source")
      destination = File.join(tmp, "site")
      FileUtils.mkdir_p(source)

      COPY_ENTRIES.each do |entry|
        next if entry == "_posts" && !include_project_posts

        original = File.join(ROOT, entry)
        FileUtils.cp_r(original, File.join(source, entry)) if File.exist?(original)
      end

      extra_files.each do |relative_path, content|
        target = File.join(source, relative_path)
        FileUtils.mkdir_p(File.dirname(target))
        File.write(target, content)
      end

      config = Jekyll.configuration(
        "source" => source,
        "destination" => destination,
        "future" => true,
        "quiet" => true
      )
      Dir.chdir(source) { Jekyll::Site.new(config).process }
      yield destination
    end
  end

  def output(destination, relative_path)
    File.read(File.join(destination, relative_path))
  end
end
