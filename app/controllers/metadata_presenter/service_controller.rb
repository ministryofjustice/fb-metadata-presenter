class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize
  helper MetadataPresenter::ApplicationHelper

  def start
    @start_page = service.start_page
    render @start_page
  end

  def answers
    save_user_data # method signature

    # TODO: We need to see what to do with these line
    # because of bots/hackers/etc
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
      render @page
    else
      render template: 'errors/404', status: 404
    end
  end
end
