module MetadataPresenter
  class PreviousPage
    include ActiveModel::Model
    attr_accessor :service, :user_data, :current_page, :referer

    def page
      # what happens when a user enters in the middle of the flow
      return if no_current_or_referrer_pages? || service.no_back_link?(current_page)

      if flow.present?
        return referer_page if return_to_referer?

        TraversedPages.new(service, user_data, current_page).last
      else
        service.previous_page(current_page: current_page, referer: referer)
      end
    end

    def flow
      service.metadata['flow']
    end

    private

    def referer_page
      @referer_page ||= service.find_page_by_url(URI(referer).path)
    end

    def return_to_referer?
      current_page.standalone? ||
        (referer_page && referer_page.standalone?)
    end

    def no_current_or_referer_pages?
      current_page.blank? || referer.nil?
    end
  end
end
