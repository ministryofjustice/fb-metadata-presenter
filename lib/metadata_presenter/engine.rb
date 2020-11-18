module MetadataPresenter
  mattr_accessor :parent_controller

  class Engine < ::Rails::Engine
    isolate_namespace MetadataPresenter

    MetadataPresenter.parent_controller = '::ApplicationController'

    initializer 'local_helper.action_controller' do
      ActiveSupport.on_load :action_controller do
        helper MetadataPresenter::ApplicationHelper
      end
    end
  end
end
