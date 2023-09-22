module MetadataPresenter
  class EvaluateContentConditionals
    include ActiveModel::Model
    attr_accessor :service, :candidate_component, :user_data

    def uuids_to_include
      included_content = []
      conditionals.map do |conditional|
        conditional.expressions.map do |expression|
          expression.service = service
          case expression.operator
          when 'is'
            if expression.field_label == user_data[expression.expression_component.id]
              included_content << candidate_component.uuid
            end
          when 'is_not'
            if expression.field_label != user_data[expression.expression_component.id]
              included_content << candidate_component.uuid
            end
          when 'is_answered'
            if user_data[expression.expression_component.id].present?
              included_content << candidate_component.uuid
            end
          when 'is_not_answered'
            if user_data[expression.expression_component.id].blank?
              included_content << candidate_component.uuid
            end
          end
        end
      end
      included_content
    end

    delegate :conditionals, to: :candidate_component
  end
end
