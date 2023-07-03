module MetadataPresenter
  class PagesController < EngineController
    before_action :set_caching_header

    def show
      @user_data = load_user_data # method signature
      @page ||= service.find_page_by_url(request.env['PATH_INFO'])
      if @page
        load_autocomplete_items

        @page_answers = PageAnswers.new(@page, @user_data)
        # byebug
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
      component = @page.components.select { |c| c.type == 'multiupload' }.first
      answers = @user_data.keys.include?(component.id) ? @user_data.find(component.id).first : []

      if uploads_remaining.zero?
        I18n.t('presenter.questions.multiupload.none')
      elsif uploads_remaining == 1
        if answers.present?
          I18n.t('presenter.questions.multiupload.answered_singular')
        else
          I18n.t('presenter.questions.multiupload.singular')
        end
      elsif answers.present?
        I18n.t('presenter.questions.multiupload.answered_plural', num: uploads_remaining)
      else
        I18n.t('presenter.questions.multiupload.plural', num: uploads_remaining)
      end
    end
    helper_method :multiupload_files_remaining

    def uploads_remaining
      component = @page.components.select { |c| c.type == 'multiupload' }.first
      max_files = component.validation['max_files'].to_i
      answers = @user_data.keys.include?(component.id) ? @user_data[component.id] : []
      max_files - answers.count
    end
    helper_method :uploads_remaining

    def uploads_count
      component = @page.components.select { |c| c.type == 'multiupload' }.first
      answers = @user_data.keys.include?(component.id) ? @user_data[component.id] : []

      answers.count == 1 ? I18n.t('presenter.questions.multiupload.answered_count_singular') : I18n.t('presenter.questions.multiupload.answered_count_plural', num: answers.count)
    end
    helper_method :uploads_count

    private

    def set_caching_header
      response.headers['Cache-Control'] = 'no-store'
    end
  end
end
