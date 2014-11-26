require 'bundler/setup'
Bundler.setup

require 'active_triples'
require 'ld4l/ore_rdf'

Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec.configure do |config|
  config.color = true
  config.tty = true

  # Uncomment the following line to get errors and backtrace for deprecation warnings
  # config.raise_errors_for_deprecations!

  # Use the specified formatter
  config.formatter = :progress
end

ActiveTriples::Repositories.add_repository :default, RDF::Repository.new
