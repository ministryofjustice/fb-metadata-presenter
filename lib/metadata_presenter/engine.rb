module MetadataPresenter
  mattr_accessor :parent_controller

  class Engine < ::Rails::Engine
    isolate_namespace MetadataPresenter

    MetadataPresenter.parent_controller = '::ApplicationController'
  end
end
