module MetadataPresenter
  class PostcodeValidator < BaseValidator
    require 'uk_postcode'

    VALIDATABLE_COUNTRIES = [
      'UK',
      'U.K.',
      'England',
      'United Kingdom',
      'Scotland',
      'Wales',
      'Cymru',
      'Channel Islands',
      'Isle of Man',
      'Northern Ireland'
    ].freeze

    def valid?
      validate_postcode if postcode.present?

      user_answer.errors.empty?
    end

    private

    def country
      user_answer.country
    end

    def postcode
      user_answer.postcode
    end

    def parsed_postcode
      @parsed_postcode ||= UKPostcode.parse(postcode)
    end

    def valid_postcode?
      parsed_postcode.full_valid?
    end

    def validatable_country?
      VALIDATABLE_COUNTRIES.grep(/\A#{country}\z/i).any?
    end

    def validate_postcode
      return if !validatable_country? || valid_postcode?

      page_answers.errors.add([component.id, :postcode].join('.'), default_error_message)
      user_answer.errors.add(:postcode, default_error_message)
    end
  end
end
