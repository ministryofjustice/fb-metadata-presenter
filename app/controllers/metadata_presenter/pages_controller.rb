module MetadataPresenter
  class PagesController < EngineController
    def show
      @user_data = load_user_data # method signature
      @page ||= service.find_page_by_url(request.env['PATH_INFO'])

      if @page
        @page_answers = PageAnswers.new(@page, @user_data)
        render template: @page.template
      else
        not_found
      end
    end

    def pages_presenters
      PageAnswersPresenter.map(
        view: view_context,
        pages: service.pages,
        answers: @user_data
      )
    end
    helper_method :pages_presenters
  end
end
