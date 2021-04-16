module MetadataPresenter
  class PageComponentsNotDefinedError < StandardError
  end

  class Page < MetadataPresenter::Metadata
    include ActiveModel::Validations

    NOT_EDITABLE = %i[
      _uuid
      _id
      _type
      steps
      add_component
      add_extra_component
    ].freeze

    def uuid
      _uuid
    end

    def ==(other)
      id == other.id if other.respond_to? :id
    end

    def editable_attributes
      to_h.reject { |k, _| k.in?(NOT_EDITABLE) }
    end

    def components
      to_components(metadata.components, collection: :components)
    end

    def extra_components
      to_components(metadata.extra_components, collection: :extra_components)
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

    def to_components(node_components, collection:)
      node_components&.map do |component|
        MetadataPresenter::Component.new(
          component.merge(collection: collection),
          editor: editor?
        )
      end
    end

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
