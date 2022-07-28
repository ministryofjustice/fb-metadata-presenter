module MetadataPresenter
  class PageComponentsNotDefinedError < StandardError
  end

  class Page < MetadataPresenter::Metadata
    include ActiveModel::Validations

    NOT_EDITABLE = %i[
      _uuid
      _id
      _type
      add_component
      add_extra_component
    ].freeze
    QUESTION_PAGES = %w[page.singlequestion page.multiplequestions].freeze
    USES_HEADING = %w[
      page.content
      page.checkanswers
      page.confirmation
      page.multiplequestions
      page.exit
    ].freeze
    END_OF_ROUTE_PAGES = %w[
      page.checkanswers
      page.confirmation
      page.exit
    ].freeze

    def editable_attributes
      to_h.reject { |k, _| k.in?(NOT_EDITABLE) }
    end

    def find_component_by_uuid(uuid)
      all_components.find { |component| component.uuid == uuid }
    end

    def all_components
      [components, extra_components].flatten.compact
    end

    def components
      @components ||=
        to_components(metadata.components, collection: :components)
    end

    def extra_components
      to_components(metadata.extra_components, collection: :extra_components)
    end

    def input_components
      all_components.reject(&:content?)
    end

    def content_components
      all_components.select(&:content?)
    end

    def supported_components_by_type(type)
      supported = supported_components(raw_type)[type]

      all_components.select do |component|
        supported.include?(component.type)
      end
    end

    def to_partial_path
      type.gsub('.', '/')
    end

    def template
      "metadata_presenter/#{type.gsub('.', '/')}"
    end

    def supported_input_components
      supported_components(raw_type)[:input]
    end

    def supported_content_components
      supported_components(raw_type)[:content]
    end

    def upload_components
      components.select(&:upload?)
    end

    def standalone?
      type == 'page.standalone'
    end

    def question_page?
      type.in?(QUESTION_PAGES)
    end

    def title
      return heading if heading?

      components.first.humanised_title
    end

    def end_of_route?
      type.in?(END_OF_ROUTE_PAGES)
    end

    def multiple_questions?
      type == 'page.multiplequestions'
    end

    def autocomplete_component_present?
      components.any?(&:autocomplete?)
    end

    def assign_autocomplete_items(items)
      component_uuids = items.keys
      components.each do |component|
        component.items = items[component.uuid] if component.uuid.in?(component_uuids)
      end
    end

    private

    def heading?
      type.in?(USES_HEADING) || Array(components).size != 1
    end

    def to_components(node_components, collection:)
      Array(node_components).map do |component|
        MetadataPresenter::Component.new(
          component.merge(collection: collection),
          editor: editor?
        )
      end
    end

    def supported_components(page_type)
      values = Rails.application.config.supported_components[page_type]
      if values.blank?
        raise PageComponentsNotDefinedError, "No supported components defined for #{page_type} in config initialiser"
      end

      values
    end

    def raw_type
      type.gsub('page.', '')
    end
  end
end
