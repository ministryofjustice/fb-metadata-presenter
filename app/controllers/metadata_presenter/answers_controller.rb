module MetadataPresenter
  class AnswersController < EngineController
    before_action :check_page_exists

    def create
      @page_answers = PageAnswers.new(page, answers_params)

      upload_file if upload?

      if @page_answers.validate_answers
        save_user_data # method signature
        redirect_to_next_page
      else
        render_validation_error
      end
    end

    private

    def page
      @page ||= begin
        current_page = service.find_page_by_url(page_url)
        MetadataPresenter::Page.new(current_page.metadata) if current_page
      end
    end

    def redirect_to_next_page
      next_page = NextPage.new(service).find(
        session: session,
        current_page_url: page_url
      )

      if next_page.present?
        redirect_to_page next_page.url
      else
        not_found
      end
    end

    def render_validation_error
      @user_data = answers_params
      render template: page.template, status: :unprocessable_entity
    end

    def answers_params
      params[:answers] ? params[:answers].permit! : {}
    end

    def page_url
      request.env['PATH_INFO']
    end

    def check_page_exists
      not_found if page.blank?
    end

    def upload_file
      super if defined?(super)
    end

    def upload?
      Array(page.components).any?(&:upload?)
    end
  end
end
