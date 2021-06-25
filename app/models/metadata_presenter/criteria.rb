module MetadataPresenter
  class Criteria < MetadataPresenter::Metadata
    attr_accessor :service

    def ==(other)
      metadata == other.metadata
    end

    def criteria_page
      service.find_page_by_uuid(page)
    end

    def criteria_component
      criteria_page.find_component_by_uuid(component)
    end

    def criteria_field
      criteria_component.find_item_by_uuid(field)
    end

    def field_label
      criteria_field['label'] if criteria_field
    end
  end
end
