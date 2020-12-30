module MetadataPresenter
  mattr_accessor :parent_controller

  class Engine < ::Rails::Engine
    isolate_namespace MetadataPresenter

    MetadataPresenter.parent_controller = '::ApplicationController'

    def fixtures_directory
      @_fixtures_directory ||=
        Pathname.new(MetadataPresenter::Engine.root.join('lib', 'fixtures'))
    end
  end
end
