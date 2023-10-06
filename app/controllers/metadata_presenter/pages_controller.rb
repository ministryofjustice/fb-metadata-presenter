module MetadataPresenter
  class PagesController < EngineController
    before_action :set_caching_header

    def show
      @user_data = load_user_data # method signature

      @page ||= service.find_page_by_url(request.env['PATH_INFO'])
      if @page
        load_autocomplete_items
        if single_page_preview?
          @page.load_all_conditional_content
        else
          @page.load_conditional_content(service, @user_data)
        end

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

    def show_save_and_return
      @page.upload_components.none?
    end
    helper_method :show_save_and_return

    def answered_pages
      TraversedPages.new(service, load_user_data, @page).all
    end

    def single_page_preview?
      return true if request.referrer.blank?

      !URI(request.referrer).path.split('/').include?('preview')
    end
    helper_method :single_page_preview?

    def conditional_components_present?
      @page.conditional_components.present?
    end
    helper_method :conditional_components_present?

    private

    def set_caching_header
      response.headers['Cache-Control'] = 'no-store'
    end
  end
end
