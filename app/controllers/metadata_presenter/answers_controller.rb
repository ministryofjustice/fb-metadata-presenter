module MetadataPresenter
  class AnswersController < EngineController
    def create
      if page.validate_answers(answers_params)
        save_user_data # method signature
        redirect_to_next_page
      else
        render_validation_error
      end
    end

    private

    def page
      @page ||= MetadataPresenter::Page.new(
        service.find_page(params[:page_url]).metadata
      )
    end

    def redirect_to_next_page
      next_page = NextPage.new(service).find(
        session: session,
        current_page_url: params[:page_url]
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
  end
end
