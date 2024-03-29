# frozen_string_literal: true

require_relative "lib/version"

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-external-callout"
  spec.version       = Asciidoctor::External::Callout::VERSION
  spec.authors       = ["Ray Offiah"]
  spec.email         = ["clogs-wrench-0z@icloud.com"]

  spec.summary       = "Asciidoc extension for adding callouts without marking up the source listing block."
  spec.description   = "If you can't add callout markers to your source listing" \
 "(if you need to keep a shell script runnable for example), then use this."
  spec.homepage      = "https://github.com/RayOffiah/asciidoctor-external-callout-ruby"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/RayOffiah/asciidoctor-external-callout-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/RayOffiah/asciidoctor-external-callout-ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html

  spec.add_dependency "asciidoctor", "~>2.0"
end
