module MetadataPresenter
  class AutocompleteValidator < BaseValidator
    attr_reader :autocomplete_items

    def initialize(page_answers:, component:, autocomplete_items:)
      super(page_answers:, component:)

      @autocomplete_items = autocomplete_items
    end

    def invalid_answer?
      return if autocomplete_item_list.blank?

      Rails.logger.info('********************')
      Rails.logger.info(user_answer)

      autocomplete_item_list.exclude?(JSON.parse(sanitized_user_answer))
    end

    def autocomplete_item_list
      @autocomplete_item_list ||= autocomplete_items[component.uuid]
    end

    private

    def sanitized_user_answer
      user_answer.gsub('&amp;', '&')
      user_answer.gsub('\u0026', '&')
    end
  end
end
