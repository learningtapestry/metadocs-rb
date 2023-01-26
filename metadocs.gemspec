# frozen_string_literal: true

require_relative 'lib/metadocs/version'

Gem::Specification.new do |spec|
  spec.name          = 'metadocs'
  spec.version       = Metadocs::VERSION
  spec.authors       = ['Rômulo Saksida']
  spec.email         = ['romulo@rsaksida.com']

  spec.summary       = 'Metadocs extracts structured data from Google Docs documents annotated with a special language.'
  spec.homepage      = 'https://github.com/learningtapestry/metadocs'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.6.8')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Dev dependencies
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'googleauth'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-minitest'

  # Runtime dependencies
  spec.add_runtime_dependency 'google-api-client', '>= 0.52'
  spec.add_runtime_dependency 'hashie', '>= 3.6'
  spec.add_runtime_dependency 'parslet', '>= 2.0'
end
