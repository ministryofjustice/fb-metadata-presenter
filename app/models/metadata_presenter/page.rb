module MetadataPresenter
  class PageComponentsNotDefinedError < StandardError
  end

  class Page < MetadataPresenter::Metadata
    include ActiveModel::Validations

    def uuid
      _uuid
    end

    def ==(other)
      id == other.id if other.respond_to? :id
    end

    def editable_attributes
      to_h.reject { |k, _| k.in?(%i[_id _type steps]) }
    end

    def components
      metadata.components&.map do |component|
        MetadataPresenter::Component.new(component, editor: editor?)
      end
    end

    def to_partial_path
      type.gsub('.', '/')
    end

    def template
      "metadata_presenter/#{type.gsub('.', '/')}"
    end

    def input_components
      page_components(raw_type)[:input_components]
    end

    def content_components
      page_components(raw_type)[:content_components]
    end

    private

    def page_components(page_type)
      values = Rails.application.config.page_components[page_type]
      if values.blank?
        raise PageComponentsNotDefinedError, "No page components defined for #{page_type} in config initialiser"
      end

      values
    end

    def raw_type
      type.gsub('page.', '')
    end
  end
end
