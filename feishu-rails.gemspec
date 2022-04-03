# frozen_string_literal: true

require_relative "lib/feishu/version"

Gem::Specification.new do |spec|
  spec.name        = "feishu-rails"
  spec.version     = Feishu::VERSION
  spec.authors     = ["WENWU.YAN"]
  spec.email       = ["careline@foxmail.com"]
  spec.homepage    = "https://github.com/ciscolive/feishu-rails"
  spec.summary     = "主要实现对接飞书机器人"
  spec.description = "use faraday send alerts to feishu robot"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ciscolive/feishu-rails"
  spec.metadata["changelog_uri"]   = "https://github.com/ciscolive/feishu-rails/blob/main/README.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails"
end
