module MetadataPresenter
  class EvaluateContentConditionals
    include ActiveModel::Model
    attr_accessor :service, :candidate_component, :user_data

    def show_component
      component_uuid
    end

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
          when 'always'
            included_content << candidate_component.uuid
          when 'never'
            next
          end
        end
      end
      included_content
    end

    def component_uuid
      @results ||=
        conditionals.map do |conditional|
          evaluated_expressions = conditional.expressions.map do |expression|
            expression.service = service
            Operator.new(
              expression.operator
            ).evaluate(
              expression.field_label,
              user_data[expression.expression_component.id]
            )
          end

          if conditional.type == 'or' && evaluated_expressions.any?
            candidate_component.uuid
          elsif evaluated_expressions.all?
            candidate_component.uuid
          end
        end
      @results.flatten.compact.first
    end

    delegate :conditionals, to: :candidate_component
  end
end
