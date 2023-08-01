module MetadataPresenter
  class EvaluateContentConditionals
    include ActiveModel::Model
    attr_accessor :service, :component, :user_data

    def show_component
      component_uuid
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
            component.uuid
          elsif evaluated_expressions.all?
            component.uuid
          end
        end
      @results.flatten.compact.first
    end

    delegate :conditionals, to: :component
  end
end
