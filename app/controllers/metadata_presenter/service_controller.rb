class MetadataPresenter::ServiceController < MetadataPresenter.parent_controller.constantize
  helper MetadataPresenter::ApplicationHelper
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def start
    @page = service.start_page
    render template: @page.template
  end

  def answers
    @page = MetadataPresenter::Page.new(service.find_page(params[:page_url]).metadata)

    if @page.validate_answers(answers_params)
      redirect_to_next_page
    else
      render_validation_error
    end
  end

  def render_page
    @user_data = load_user_data # method signature

    # we need verify that the user can't jump pages??
    #
    @page = service.find_page(request.env['PATH_INFO'])

    if @page
      render template: @page.template
    else
      render template: 'errors/404', status: 404
    end
  end

  def back_link
    return if @page.blank?

    @back_link ||= service.previous_page(current_page: @page)&.url
  end
  helper_method :back_link

  private

  def redirect_to_next_page
    save_user_data # method signature
    next_page = service.next_page(from: params[:page_url])

    if next_page.present?
      redirect_to File.join(request.script_name, next_page.url)
    else
      render template: 'errors/404', status: 404
    end
  end

  def render_validation_error
    @user_data = answers_params
    render template: @page.template, status: :unprocessable_entity
  end

  def answers_params
    params[:answers] ? params[:answers].permit! : {}
  end
end
