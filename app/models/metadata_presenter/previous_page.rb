module MetadataPresenter
  class PreviousPage
    include ActiveModel::Model
    attr_accessor :service, :user_data, :current_page, :referer

    def page
      return if current_page.blank?

      if flow.present?
        previous_page = TraversedPages.new(service, user_data).last

        return previous_page if previous_page

        service.start_page
      else
        service.previous_page(
          current_page: current_page,
          referrer: referer
        )
      end
    end

    def flow
      service.metadata['flow']
    end
  end
end
