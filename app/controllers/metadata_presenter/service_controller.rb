class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize
  helper MetadataPresenter::ApplicationHelper

  def start
    @start_page = service.start_page
    render template: @start_page.template
  end

  def answers
    save_user_data # method signature

    current_page = URI(request.referer).path
    next_page = service.next_page(from: current_page)

    if next_page.present?
      redirect_to next_page.url
    else
      render template: 'errors/404', status: 404
    end
  end

  def render_page
    load_user_data # method signature

    # we need verify that the user can't jump pages??
    #
    @page = service.find_page(request.path)

    if @page
      render template: @page.template
    else
      render template: 'errors/404', status: 404
    end
  end

  def service
    MetadataPresenter::Service.new(service_metadata)
  end
end
