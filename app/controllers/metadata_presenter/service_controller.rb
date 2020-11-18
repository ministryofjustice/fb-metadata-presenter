class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize

  def start
    @service = MetadataPresenter::Service.new(service_metadata)
    @start_page = @service.pages.first
  end
end
