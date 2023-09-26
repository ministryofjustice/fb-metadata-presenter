module MetadataPresenter
  class EvaluateContentConditionals
    include ActiveModel::Model
    attr_accessor :service, :user_data

    def evaluate_content_components(page)
      displayed_components = []
      page.content_components.map do |content_component|
        next if page.conditionals_uuids_by_type('never').include?(content_component.uuid)

        if page.conditionals_uuids_by_type('always').include?(content_component.uuid)
          displayed_components << content_component.uuid
        end
        if page.conditionals_uuids_by_type('conditional').include?(content_component.uuid)
          displayed_components << uuid_to_include?(content_component)
        end
      end
      displayed_components.compact
    end

    private

    def uuid_to_include?(candidate_component)
      evaluation_expressions = []
      candidate_component.conditionals[0].expressions.map do |expression|
        expression.service = service
        case expression.operator
        when 'is'
          evaluation_expressions << check_answer_equal_expression(expression, user_data)
        when 'is_not'
          evaluation_expressions << !check_answer_equal_expression(expression, user_data)
        when 'is_answered'
          evaluation_expressions << user_data[expression.expression_component.id].present?
        when 'is_not_answered'
          evaluation_expressions << user_data[expression.expression_component.id].blank?
        when 'contains'
          evaluation_expressions << check_answer_include_expression(expression, user_data)
        when 'does_not_contain'
          evaluation_expressions << !check_answer_include_expression(expression, user_data)
        end
      end
      return candidate_component.uuid if evaluation_expressions.all?
    end

    def check_answer_equal_expression(expression, user_data)
      expression.field_label == user_data[expression.expression_component.id]
    end

    def check_answer_include_expression(expression, user_data)
      answer = user_data[expression.expression_component.id]
      return false if answer.blank?

      expression.field_label.include?(answer.first)
    end
  end
end
