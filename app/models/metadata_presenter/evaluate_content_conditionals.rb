module MetadataPresenter
  class EvaluateContentConditionals
    include ActiveModel::Model
    attr_accessor :service, :component, :user_data

    # returns true/false whether the component should display
    def display?
      return false if component.display == 'never'
      return true if component.display == 'always'
      # returns true if any conditionals match (OR)
      conditionals.any? do |conditional|
        # returns true if all expressions match (AND)
        conditional.expressions.all? do |expression|
          expression.service = service

          Operator.new(
            expression.operator
          ).evaluate(
            expression.field_label,
            user_data[expression.expression_component.id]
          )
        end
      end
    end

    delegate :conditionals, to: :component
  end
end
