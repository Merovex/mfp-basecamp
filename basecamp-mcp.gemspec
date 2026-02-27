# frozen_string_literal: true

require_relative 'lib/basecamp_mcp/version'

Gem::Specification.new do |spec|
  spec.name          = 'basecamp-mcp'
  spec.version       = BasecampMcp::VERSION
  spec.summary       = 'Full-coverage MCP server for the Basecamp 4 API'
  spec.description   = 'A Ruby MCP server providing ~137 tools covering the entire Basecamp 4 API surface. ' \
                       'Uses the official MCP Ruby SDK with STDIO transport for Claude Desktop integration.'
  spec.authors       = ['Merovex']
  spec.license       = 'MIT'
  spec.homepage      = 'https://github.com/merovex/basecamp-mcp'

  spec.required_ruby_version = '>= 3.1.0'

  spec.files         = Dir['lib/**/*.rb', 'bin/*', 'LICENSE', 'README.md']
  spec.bindir        = 'bin'
  spec.executables   = ['basecamp-mcp']

  spec.add_dependency 'faraday', '~> 2.0'
  spec.add_dependency 'mcp', '~> 0.7'
  spec.add_dependency 'webrick', '~> 1.8'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.0'
  spec.add_development_dependency 'webmock', '~> 3.0'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
