class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize
  helper MetadataPresenter::ApplicationHelper

  def start
    @service = MetadataPresenter::Service.new(service_metadata) # method signature
    @start_page = @service.start_page
    render template: @start_page.template
  end

  def answers
    save_user_data # method signature

    @service = MetadataPresenter::Service.new(service_metadata) # method signature
    current_page = URI(request.referer).path
    redirect_to @service.next_page(from: current_page).url
  end

  def render_page
    load_user_data # method signature

    # we need verify that the user can't jump pages??
    #
    @service = MetadataPresenter::Service.new(service_metadata)
    @page = @service.find_page(request.path)

    if @page
      render template: @page.template
    else
      render template: 'errors/404'
    end
  end
end
