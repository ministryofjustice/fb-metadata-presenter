module MetadataPresenter
  class EvaluateContentConditionals
    include ActiveModel::Model
    attr_accessor :service, :candidate_component, :user_data
    
    def uuids_to_include
      conditionals.map do |conditional|
        evaluation_expressions = []
        conditional.expressions.map do |expression|
          expression.service = service
          case expression.operator
          when 'is'
            if expression.field_label == user_data[expression.expression_component.id]
              evaluation_expressions << true
            end
          when 'is_not'
            if expression.field_label != user_data[expression.expression_component.id]
              evaluation_expressions << true
            end
          when 'is_answered'
            if user_data[expression.expression_component.id].present?
              evaluation_expressions << true
            end
          when 'is_not_answered'
            if user_data[expression.expression_component.id].blank?
              evaluation_expressions << true
            end
          end
        end
        return candidate_component.uuid if evaluation_expressions.all?
      end
    end

    delegate :conditionals, to: :candidate_component
  end
end
