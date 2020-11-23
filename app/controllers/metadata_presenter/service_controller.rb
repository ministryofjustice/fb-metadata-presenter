class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize
  helper MetadataPresenter::ApplicationHelper

  def start
    @service = MetadataPresenter::Service.new(service_metadata)
    @start_page = @service.start_page
    render template: @start_page.template
  end

  def answers
    redirect_to 'page-2'
  end

  def page
    @service = MetadataPresenter::Service.new(service_metadata)
    @page = @service.next_page(params[:path])
    if @page
      render template: @page.template
    else
      render template: 'errors/404'
    end
  end
end
