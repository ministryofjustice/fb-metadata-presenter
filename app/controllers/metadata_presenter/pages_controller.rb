module MetadataPresenter
  class PagesController < EngineController
    before_action :set_caching_header

    def show
      @user_data = load_user_data # method signature
      @page ||= service.find_page_by_url(request.env['PATH_INFO'])

      if @page
        load_autocomplete_items
        # byebug
        @page_answers = PageAnswers.new(@page, @user_data)
        byebug
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

    def multiupload_files_remaining
      # byebug
      max_files = @page.components.select {|c| c.type == 'multiupload' }.first['max_files'].to_i
      answered = true
      if(max_files == 1)
        if(answered)
          I18n.t('presenter.questions.multiupload.answered_singular')
        else
          I18n.t('presenter.questions.multiupload.singular')
        end
      else
        if(answered)
          I18n.t('presenter.questions.multiupload.answered_plural', max: max_files)
        else
          I18n.t('presenter.questions.multiupload.plural', max: max_files)
        end
      end
    end
    helper_method :multiupload_files_remaining

    private

    def set_caching_header
      response.headers['Cache-Control'] = 'no-store'
    end
  end
end
