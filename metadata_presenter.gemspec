$:.push File.expand_path('lib', __dir__)

require 'metadata_presenter/version'

Gem::Specification.new do |spec|
  spec.name        = 'metadata_presenter'
  spec.version     = MetadataPresenter::VERSION
  spec.authors     = ["MoJ Online"]
  spec.email       = ["moj-online@digital.justice.gov.uk"]
  spec.homepage    = 'https://moj-online.service.justice.gov.uk'
  spec.summary     = 'Service Metadata Presenter'
  spec.description = 'Service Metadata Presenter for the Form Builder product'
  spec.license     = 'MIT'

  spec.files = Dir['{app,config,db,lib}/**/*', 'MIT-LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'rails', '>= 6.0.3.4', '< 6.2.0'
  spec.add_dependency 'kramdown', '>= 2.3.0'
  spec.add_dependency 'govuk_design_system_formbuilder', '>= 2.1.5'
  spec.add_dependency 'json-schema', '>= 2.8.1'

  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'better_errors'
  spec.add_development_dependency 'binding_of_caller'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'site_prism'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'brakeman'
end
