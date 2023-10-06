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
      save_and_return.resume_progress
    ].freeze
    END_OF_ROUTE_PAGES = %w[
      page.checkanswers
      page.confirmation
      page.exit
      save_and_return.resume_progress
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

    def multiupload_components
      components.select(&:multiupload?)
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

    def contains_placeholders?
      return false if placeholders.empty?

      regex = /#{placeholders.map { |p| Regexp.escape(p) }.join('|')}/
      regex.match?(body)
    end

    def placeholders
      return [] unless standalone?

      key = id.gsub('page.', '')

      begin
        I18n.t("presenter.footer.#{key}.placeholders", raise: true)
      rescue I18n::MissingTranslationData
        []
      end
    end

    def conditional_content_to_show
      @conditional_content_to_show || []
    end

    def show_conditional_component?(component_id)
      conditional_content_to_show.include?(component_id)
    end

    def load_conditional_content(service, user_data)
      if content_component_present?
        evaluator = EvaluateContentConditionals.new(service:, user_data:)
        items = evaluator.evaluate_content_components(self)
        items << conditional_component_shown_by_default
        assign_conditional_component(items.flatten)
      end
    end

    def conditionals_uuids_by_type(display)
      all_components.filter_map { |component| component[:_uuid] if component[:display] == display }
    end

    def load_all_conditional_content
      @conditional_content_to_show = all_conditional_content
    end

    def conditional_components
      never = conditionals_uuids_by_type('never')
      only_if = conditionals_uuids_by_type('conditional')
      never + only_if
    end

    private

    def heading?
      type.in?(USES_HEADING) || Array(components).size != 1
    end

    def to_components(node_components, collection:)
      Array(node_components).map do |component|
        MetadataPresenter::Component.new(
          component.merge(collection:),
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

    def assign_conditional_component(items)
      @conditional_content_to_show = items
    end

    def content_component_present?
      components.any?(&:content?)
    end

    def conditional_component_shown_by_default
      default_components = all_components - all_conditional_content
      default_components.map { |component| component[:_uuid] }
    end

    def all_conditional_content
      all_components { |component| component[:display].present? }
    end
  end
end
