$:.push File.expand_path('lib', __dir__)

require 'metadata_presenter/version'

Gem::Specification.new do |spec|
  spec.name        = 'metadata_presenter'
  spec.version     = MetadataPresenter::VERSION
  spec.authors     = ['MoJ Forms']
  spec.email       = ['moj-forms@digital.justice.gov.uk']
  spec.homepage    = 'https://moj-forms.service.justice.gov.uk/'
  spec.summary     = 'Service Metadata Presenter'
  spec.description = 'Service Metadata Presenter for the MoJ Forms product'
  spec.license     = 'MIT'

  spec.files = Dir[
    '{app,config,db,default_metadata,default_text,lib,fixtures,schemas}/**/*',
    'MIT-LICENSE',
    'Rakefile',
    'README.md'
  ]

  spec.add_dependency 'govuk_design_system_formbuilder', '~> 4.1.1'
  spec.add_dependency 'json-schema', '~> 4.1.1'
  spec.add_dependency 'kramdown', '~> 2.4.0'
  spec.add_dependency 'govspeak', '~> 7.1'
  spec.add_dependency 'rails', '~> 7.0.0'
  spec.add_dependency 'sassc-rails', '2.1.2'
  spec.add_dependency 'sprockets-rails'
  spec.add_dependency 'sprockets'
  spec.add_dependency 'uk_postcode'


  spec.add_development_dependency 'better_errors'
  spec.add_development_dependency 'binding_of_caller'
  spec.add_development_dependency 'brakeman'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'hashie'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-govuk'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-console'
  spec.add_development_dependency 'site_prism', '< 5.0'
  spec.add_development_dependency 'yard'
end
