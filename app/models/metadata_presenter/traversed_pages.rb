module MetadataPresenter
  class TraversedPages
    attr_reader :service, :user_data, :current_page

    def initialize(service, user_data, current_page)
      @service = service
      @user_data = user_data
      @pages = [service.start_page]
      @current_page = current_page
    end

    delegate :last, to: :all

    def all
      page_uuid = service.start_page.uuid

      service.flow.size.times do
        break if page_uuid == current_page.uuid

        flow_object = service.flow_object(page_uuid)

        if flow_object.branch?
          page = EvaluateConditions.new(
            service: service,
            flow: flow_object,
            user_data: user_data
          ).page
          page_uuid = page.uuid
        else
          page_uuid = flow_object.default_next
          page = service.find_page_by_uuid(page_uuid)
        end

        @pages.push(page) if page && page.uuid != current_page.uuid
      end

      @pages
    end
  end
end
