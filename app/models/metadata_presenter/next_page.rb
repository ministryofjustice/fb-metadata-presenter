module MetadataPresenter
  class NextPage
    attr_reader :service

    def initialize(service)
      @service = service
    end

    def find(session:, current_page_url:)
      if session[:return_to_check_you_answer].present?
        session[:return_to_check_you_answer] = nil
        service.pages.find { |page| page.type == 'page.summary' }
      else
        service.next_page(from: current_page_url)
      end
    end
  end
end
