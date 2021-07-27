module MetadataPresenter
  class PreviousPage
    include ActiveModel::Model
    attr_accessor :service, :user_data, :current_page, :referrer

    def page
      return if no_current_or_referrer_pages? || service.no_back_link?(current_page)

      return referrer_page if return_to_referrer?

      TraversedPages.new(service, user_data, current_page).last
    end

    private

    def referrer_page
      @referrer_page ||= service.find_page_by_url(URI(referrer).path)
    end

    def return_to_referrer?
      return false unless current_page.standalone?

      current_page.standalone? ||
        (referrer_page && referrer_page.standalone?)
    end

    def no_current_or_referrer_pages?
      current_page.blank? || referrer.nil?
    end
  end
end
