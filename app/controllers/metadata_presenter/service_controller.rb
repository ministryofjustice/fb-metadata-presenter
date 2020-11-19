class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize
  helper MetadataPresenter::ApplicationHelper

  def start
    @service = MetadataPresenter::Service.new(service_metadata)
    @start_page = @service.start_page
  end
end
