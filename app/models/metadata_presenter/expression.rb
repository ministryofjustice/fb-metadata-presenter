module MetadataPresenter
  class Expression < MetadataPresenter::Metadata
    attr_accessor :service

    def ==(other)
      metadata == other.metadata
    end

    def expression_page
      @expression_page ||= service.find_page_by_uuid(page)
    end

    def expression_component
      @expression_component ||= expression_page.find_component_by_uuid(component)
    end

    def expression_field
      expression_component.find_item_by_uuid(field)
    end

    def field_label
      expression_field['label'] if expression_field
    end
  end
end
