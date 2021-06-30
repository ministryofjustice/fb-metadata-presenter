module MetadataPresenter
  class PreviousPage
    include ActiveModel::Model
    attr_accessor :service, :user_data, :current_page, :referrer

    def page
      # what happens when a user enters in the middle of the flow
      return if no_current_or_referrer_pages? || service.no_back_link?(current_page)

      if flow.present?
        return referrer_page if return_to_referrer?

        TraversedPages.new(service, user_data, current_page).last
      else
        service.previous_page(current_page: current_page, referrer: referrer)
      end
    end

    def flow
      service.metadata['flow']
    end

    private

    def referrer_page
      @referrer_page ||= service.find_page_by_url(URI(referrer).path)
    end

    def return_to_referrer?
      current_page.standalone? ||
        (referrer_page && referrer_page.standalone?)
    end

    def no_current_or_referrer_pages?
      current_page.blank? || referrer.nil?
    end
  end
end
