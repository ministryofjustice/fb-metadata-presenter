module MetadataPresenter
  class EngineController < MetadataPresenter.parent_controller.constantize
    protect_from_forgery with: :exception

    helper MetadataPresenter::ApplicationHelper
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder
  end
end
