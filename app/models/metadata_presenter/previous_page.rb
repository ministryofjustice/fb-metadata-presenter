module MetadataPresenter
  class PreviousPage
    include ActiveModel::Model
    attr_accessor :service, :user_data, :current_page, :referer

    def page
      return if current_page.blank? || service.no_back_link?(current_page)

      if flow.present?
        previous_page = TraversedPages.new(service, user_data, current_page).last

        return previous_page if previous_page
      else
        service.previous_page(current_page: current_page)
      end
    end

    def flow
      service.metadata['flow']
    end
  end
end
