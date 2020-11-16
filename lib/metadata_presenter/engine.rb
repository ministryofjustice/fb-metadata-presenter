module MetadataPresenter
  class Engine < ::Rails::Engine
    isolate_namespace MetadataPresenter

    initializer 'local_helper.action_controller' do
      ActiveSupport.on_load :action_controller do
        helper MetadataPresenter::ApplicationHelper
      end
    end

  end
end
