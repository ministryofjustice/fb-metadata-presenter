class MetadataPresenter::Component < MetadataPresenter::Metadata
  VALIDATION_BUNDLES = {
    'date' => 'date',
    'number' => 'number',
    'text' => 'string',
    'textarea' => 'string'
  }.freeze

  # Used for max_length and max_word validations.
  # Threshold percentage at which the remaining count is shown
  VALIDATION_STRING_LENGTH_THRESHOLD = 75

  def to_partial_path
    "metadata_presenter/component/#{type}"
  end

  def humanised_title
    label || legend
  end

  def items
    Array(metadata.items).map do |item|
      MetadataPresenter::Item.new(item, editor: editor?)
    end
  end

  SUPPORTS_BRANCHING = %w[radios checkboxes].freeze

  def supports_branching?
    type.in?(SUPPORTS_BRANCHING)
  end

  def content?
    type == 'content'
  end

  def upload?
    type == 'upload'
  end

  def find_item_by_uuid(uuid)
    items.find { |item| item.uuid == uuid }
  end

  def supported_validations
    return [] if validation_bundle_key.nil?

    JSON::Validator.schema_for_uri(validation_bundle_key)
                   .schema['properties']['validation']['properties']
                   .keys
  end

  def validation_threshold
    VALIDATION_STRING_LENGTH_THRESHOLD
  end

  private

  def validation_bundle_key
    @validation_bundle_key ||=
      if type.in?(VALIDATION_BUNDLES.keys)
        definition_bundle = VALIDATION_BUNDLES[type]
        "validations.#{definition_bundle}_bundle"
      end
  end
end
