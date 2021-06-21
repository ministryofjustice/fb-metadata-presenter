module MetadataPresenter
  class NextPage
    include ActiveModel::Model
    attr_accessor :service, :session, :current_page_url

    def find
      return check_answers_page if return_to_check_you_answer?

      if conditions?
        evaluate_conditions
      else
        # flow['default']
        service.next_page(from: current_page_url)
      end
    end

    private

    def check_answers_page
      session[:return_to_check_you_answer] = nil
      service.pages.find { |page| page.type == 'page.checkanswers' }
    end

    def return_to_check_you_answer?
      session[:return_to_check_you_answer].present?
    end

    def conditions?
      # change this to if the next page is a branch object
      current_page_flow.present? &&
        next_flow.present? &&
        next_flow_conditions.present?
    end

    def evaluate_conditions
      EvaluateConditions.new(
        service: service,
        flow: next_flow,
        user_data: session[:user_data]
      ).page
    end

    def current_page
      service.find_page_by_url(current_page_url)
    end

    def current_page_uuid
      current_page.uuid
    end

    def current_page_flow
      service.flow(current_page_uuid)
    end

    def next_flow
      service.flow(current_page_flow.default_next)
    end

    def next_flow_conditions
      next_flow.conditions
    end
  end
end
