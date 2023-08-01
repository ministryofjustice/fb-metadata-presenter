module MetadataPresenter
  class EvaluateBranchConditionals
    include ActiveModel::Model
    attr_accessor :service, :flow, :user_data

    def page
      evaluated_page_uuid = page_uuid || flow.default_next

      service.find_page_by_uuid(evaluated_page_uuid)
    end

    def page_uuid
      @results ||= conditionals.map do |conditional|
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
          conditional.next
        elsif evaluated_expressions.all?
          conditional.next
        end
      end

      @results.flatten.compact.first
    end

    delegate :conditionals, to: :flow
  end
end
