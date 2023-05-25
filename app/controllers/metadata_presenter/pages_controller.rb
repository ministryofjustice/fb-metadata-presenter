module MetadataPresenter
  class PagesController < EngineController
    before_action :set_caching_header

    def show
      @user_data = load_user_data # method signature
      @page ||= service.find_page_by_url(request.env['PATH_INFO'])

      if @page
        load_autocomplete_items

        @page_answers = PageAnswers.new(@page, @user_data)

        render template: @page.template
      else
        not_found
      end
    end

    def pages_presenters
      PageAnswersPresenter.map(
        view: view_context,
        pages: answered_pages,
        answers: @user_data
      )
    end
    helper_method :pages_presenters

    def answered_pages
      TraversedPages.new(service, load_user_data, @page).all
    end

    private

    def set_caching_header
      response.headers['Cache-Control'] = 'no-store'
    end
  end
end
