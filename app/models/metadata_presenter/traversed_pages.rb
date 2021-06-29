module MetadataPresenter
  class TraversedPages
    attr_reader :service, :user_data, :current_page

    def initialize(service, user_data, current_page)
      @service = service
      @user_data = user_data
      @pages = [service.start_page]
      @current_page = current_page
    end

    def last
      all.last
    end

    def all
      next_page_uuid = service.start_page.uuid

      until next_page_uuid == current_page.uuid do
        flow_object = service.flow(next_page_uuid)

        if flow_object.branch?
          page = EvaluateConditions.new(
            service: service,
            flow: flow_object,
            user_data: user_data
          ).page
          # check if user answer exists
          # check if it is a content page
          # check for optional questions
          # check for multiple questions with content components only
          next_page_uuid = page.uuid
        else
          next_page_uuid = flow_object.default_next
          page = service.find_page_by_uuid(next_page_uuid)
        end

        @pages.push(page) if page && page.uuid != current_page.uuid
      end

      @pages
    end
  end
end
