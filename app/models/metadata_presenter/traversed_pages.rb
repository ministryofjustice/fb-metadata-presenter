module MetadataPresenter
  class TraversedPages
    attr_reader :service, :user_data, :current_page

    def initialize(service, user_data, current_page = nil)
      @service = service
      @user_data = user_data
      @pages = [service.start_page]
      @current_page = current_page
    end

    delegate :last, to: :all

    def all
      next_object = service.start_page

      service.flow.size.times do
        break if next_object.blank? || next_object.uuid == current_page&.uuid

        flow_object = service.flow_object(next_object.uuid)
        next_object = flow_object.branch? ? evaluated_page(flow_object) : next_flow_object(flow_object.default_next)
        @pages.push(next_object) if page_in_flow?(next_object)
      end

      @pages
    end

    private

    def evaluated_page(flow_object)
      EvaluateConditionals.new(
        service: service,
        flow: flow_object,
        user_data: user_data
      ).page
    end

    def next_flow_object(uuid)
      obj = service.flow_object(uuid)
      obj.branch? ? obj : service.find_page_by_uuid(uuid)
    end

    def page_in_flow?(obj)
      obj.is_a?(MetadataPresenter::Page) && obj.uuid != current_page&.uuid
    end
  end
end
