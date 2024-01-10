module MetadataPresenter
  class ServiceController < EngineController
    def start
      if use_external_start_page?
        return redirect_to_next_page
      end

      @page = service.start_page
      render template: @page.template
    end

    private

    def use_external_start_page?
      ENV['EXTERNAL_START_PAGE_URL'].present?
    end

    def redirect_to_next_page
      next_page = NextPage.new(
        service:,
        session:,
        user_data: reload_user_data,
        current_page_url: service.start_page.url,
        previous_answers: []
      ).find

      if next_page.present?
        redirect_to_page next_page.url
      else
        not_found
      end
    end
  end
end
