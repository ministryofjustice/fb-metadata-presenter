module MetadataPresenter
  class EvaluateConditions
    include ActiveModel::Model
    attr_accessor :service, :flow, :user_data

    def page
      results = conditions.map do |condition|
        condition.criterias.map do |criteria|
          criteria.service = service

          if Operator.new(
            criteria.operator
          ).evaluate(criteria.field_label, user_data[criteria.criteria_component.id])
            condition.next
          end
        end
      end

      page_uuid = results.flatten.uniq.compact
      if page_uuid.present?
        service.find_page_by_uuid(page_uuid.first)
      else
        service.find_page_by_uuid(flow.default_next)
      end
    end

    def conditions
      flow.conditions
    end
  end
end
