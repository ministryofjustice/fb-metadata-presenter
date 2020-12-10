class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize
  helper MetadataPresenter::ApplicationHelper
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def start
    @page = service.start_page
    render template: @page.template
  end

  def answers
    @page = MetadataPresenter::Page.new(service.find_page(params[:page_url]).metadata)

    answers_params = params[:answers] ? params[:answers].permit! : {}

    if @page.validate_answers(answers_params)
      save_user_data # method signature
      next_page = service.next_page(from: params[:page_url])

      if next_page.present?
        redirect_to File.join(request.script_name, next_page.url)
      else
        render template: 'errors/404', status: 404
      end
    else
      @user_data = params[:answers]
      render template: @page.template
    end
  end

  def render_page
    @user_data = load_user_data # method signature

    # we need verify that the user can't jump pages??
    #
    @page = service.find_page(request.env['PATH_INFO'])

    if @page
      @back_link = service.previous_page(current_page: @page)&.url
      render template: @page.template
    else
      render template: 'errors/404', status: 404
    end
  end
end
