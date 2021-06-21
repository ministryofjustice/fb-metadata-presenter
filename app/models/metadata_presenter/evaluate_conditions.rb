module MetadataPresenter
  class EvaluateConditions
    include ActiveModel::Model
    attr_accessor :service, :flow, :user_data

    def page
      results = conditions.map do |condition|
        condition.criterias.map do |criteria|
          page = service.find_page_by_uuid(criteria.page)
          component = page.find_component_by_uuid(criteria.component)
          field = component.find_item_by_uuid(criteria.field)

          Operator.new(
            criteria.operator
          ).evaluate(field['label'], user_data[component.id])
        end
      end

      if results.flatten.all?
        service.find_page_by_uuid(flow.conditions.first.next)
      else
        service.find_page_by_uuid(flow.default_next)
      end
    end

    def conditions
      flow.conditions
    end
  end
end
