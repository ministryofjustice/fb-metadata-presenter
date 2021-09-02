module MetadataPresenter
  class NextPage
    include ActiveModel::Model
    attr_accessor :service, :session, :user_data, :current_page_url, :previous_answers

    def find
      return check_answers_page if return_to_check_your_answer?

      if conditionals?
        evaluate_conditionals
      else
        service.find_page_by_uuid(current_page_flow.default_next)
      end
    ensure
      session[:return_to_check_your_answer] = nil
    end

    private

    def check_answers_page
      service.pages.find { |page| page.type == 'page.checkanswers' }
    end

    def return_to_check_your_answer?
      session[:return_to_check_your_answer].present? &&
        components_not_used_for_branching_and_answers_unchanged?
    end

    def components_not_used_for_branching_and_answers_unchanged?
      components_not_used_for_branching? && answers_unchanged?
    end

    def components_not_used_for_branching?
      expressions.none? { |expression| component_ids.include?(expression) }
    end

    def answers_unchanged?
      components = current_page_components.select do |component|
        component.uuid.in?(expressions.map(&:component))
      end

      components.all? do |component|
        user_data[component.id] == previous_answers[component.id]
      end
    end

    def component_ids
      current_page_components.map(&:id)
    end

    def current_page_components
      current_page.components
    end

    def expressions
      collection = service.branches.map do |branch|
        branch.conditionals.map(&:expressions)
      end

      collection.flatten
    end

    def conditionals?
      current_page_flow.present? &&
        next_flow.present? &&
        next_flow_branch_object?
    end

    def evaluate_conditionals
      EvaluateConditionals.new(
        service: service,
        flow: next_flow,
        user_data: user_data
      ).page
    end

    def current_page
      service.find_page_by_url(current_page_url)
    end

    def current_page_uuid
      current_page.uuid
    end

    def current_page_flow
      service.flow_object(current_page_uuid)
    end

    def next_flow
      service.flow_object(current_page_flow.default_next)
    end

    def next_flow_branch_object?
      next_flow.branch?
    end
  end
end
