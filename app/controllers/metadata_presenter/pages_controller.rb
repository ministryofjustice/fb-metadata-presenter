module MetadataPresenter
  class PagesController < EngineController
    before_action :set_caching_header

    def show
      @user_data = load_user_data # method signature

      @page ||= service.find_page_by_url(request.env['PATH_INFO'])
      if @page
        load_autocomplete_items
        load_page_content

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

    def conditional_components_present?
      @page.conditional_components.any?
    end
    helper_method :conditional_components_present?

    private

    def set_caching_header
      response.headers['Cache-Control'] = 'no-store'
    end

    def form_page_title
      if @page
        if @page.components.present?
          if @page.components.first['label'].present?
            "#{service.service_name} - #{@page.components.first['label']}"
          elsif @page.components.first['legend'].present?
            "#{service.service_name} - #{@page.components.first['legend']}"
          end
        elsif @page.heading.present?
          if @page['_type'] == 'page.standalone' && @page['_id'] == 'page.cookies'
            "#{service.service_name} - #{@page.heading}"
          else
            "#{service.service_name} - #{@page.heading}"
          end
        else
          service.service_name || 'MoJ Forms'
        end
      else
        service.service_name || 'MoJ Forms'
      end
    end
    helper_method :form_page_title
  end
end
