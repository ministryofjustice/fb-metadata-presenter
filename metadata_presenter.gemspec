$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "metadata_presenter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "metadata_presenter"
  spec.version     = MetadataPresenter::VERSION
  spec.authors     = ["Tomas D'Stefano"]
  spec.email       = ["tomas_stefano@successoft.com"]
  spec.homepage    = "http://www.example.com"
  spec.summary     = "Summary of MetadataPresenter."
  spec.description = "Description of Fb::Metadata::Presenter."
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.0.3", ">= 6.0.3.4"
  spec.add_dependency "govspeak"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "byebug"
  spec.add_development_dependency "rspec-rails"
end
