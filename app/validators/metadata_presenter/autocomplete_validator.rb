module MetadataPresenter
  class AutocompleteValidator < BaseValidator
    attr_reader :autocomplete_items

    def initialize(page_answers:, component:, autocomplete_items:)
      super(page_answers: page_answers, component: component)

      @autocomplete_items = autocomplete_items
    end

    def invalid_answer?
      return if autocomplete_item_list.blank?

      autocomplete_item_list.exclude?(JSON.parse(user_answer))
    end

    def autocomplete_item_list
      @autocomplete_item_list ||= autocomplete_items[component.uuid]
    end
  end
end