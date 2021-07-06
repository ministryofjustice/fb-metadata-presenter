module MetadataPresenter
  class EvaluateConditions
    include ActiveModel::Model
    attr_accessor :service, :flow, :user_data

    def page
      evaluated_page_uuid = page_uuid || flow.default_next

      service.find_page_by_uuid(evaluated_page_uuid)
    end

    def page_uuid
      @results ||= conditions.map do |condition|
        evaluated_criterias = condition.criterias.map do |criteria|
          criteria.service = service

          Operator.new(
            criteria.operator
          ).evaluate(
            criteria.field_label,
            user_data[criteria.criteria_component.id]
          )
        end

        if condition.condition_type == 'or' && evaluated_criterias.any?
          condition.next
        elsif evaluated_criterias.all?
          condition.next
        end
      end

      @results.flatten.compact.first
    end

    delegate :conditions, to: :flow
  end
end
