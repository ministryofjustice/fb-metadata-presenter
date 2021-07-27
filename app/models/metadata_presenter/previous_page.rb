module MetadataPresenter
  class PreviousPage
    include ActiveModel::Model
    attr_accessor :service, :user_data, :current_page, :referrer

    def page
      return if no_current_or_referrer_pages? || service.no_back_link?(current_page)

      TraversedPages.new(service, user_data, current_page).last
    end

    private

    def no_current_or_referrer_pages?
      current_page.blank? || referrer.nil?
    end
  end
end
