require 'metadata_presenter/test_helpers'

namespace :metadata do
  include MetadataPresenter::TestHelpers

  desc 'Represent the flow objects in human readable form'
  task flow: :environment do
    service = MetadataPresenter::Service.new(metadata_fixture('branching'))

    start_page = service.start_page
    flow = service.flow(start_page.uuid)
    first_page = service.find_page_by_uuid(flow.default_next)

    humanized_flow = {}

    humanized_flow[start_page.url] = {
      next: first_page.url
    }

    service.metadata['flow'].each do |id, _metadata|
      flow = service.flow(id)

      if flow.branch?
        page = service.find_page_by_uuid(flow.default_next)
        humanized_flow[page.url] = {
          conditions: flow.conditions.map do |condition|
            {
              condition_type: condition.condition_type,
              criterias: condition.criterias.map do |criteria|
                criteria.service = service
                {
                  operator: criteria.operator,
                  page: criteria.criteria_page.url,
                  component: criteria.criteria_component.humanised_title,
                  field: criteria.field_label
                }
              end
            }
          end
        }
      else
        page = service.find_page_by_uuid(id)
        next_page = service.find_page_by_uuid(flow.default_next)
        if next_page
          humanized_flow[page.url] = { next: next_page.url }
        end
      end
    end

    pp humanized_flow
  end
end
