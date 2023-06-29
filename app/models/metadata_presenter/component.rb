class MetadataPresenter::Component < MetadataPresenter::Metadata
  VALIDATION_BUNDLES = {
    'date' => 'date',
    'number' => 'number',
    'text' => 'string',
    'textarea' => 'string',
    'multiupload' => 'file'
  }.freeze

  # Used for max_length and max_word validations.
  # Threshold percentage at which the remaining count is shown
  VALIDATION_STRING_LENGTH_THRESHOLD = 75

  # Overriding here because autocomplete component's items property is non interactable
  # in the Editor therefore it does not need to exist in the data-fb-content-data
  # attribute on the page. The data-fb-content-data attribute is what is used to
  # update user interactable elements such as the component question or page section
  # heading etc.
  def to_json(*_args)
    return super unless autocomplete?

    JSON.parse(super).to_json(except: 'items')
  end

  def to_partial_path
    "metadata_presenter/component/#{type}"
  end

  def humanised_title
    label || legend
  end

  def items
    Array(metadata.items).map do |item|
      item_klass.new(item, editor: editor?)
    end
  end

  def item_klass
    autocomplete? ? MetadataPresenter::AutocompleteItem : MetadataPresenter::Item
  end

  SUPPORTS_BRANCHING = %w[radios checkboxes].freeze

  def supports_branching?
    type.in?(SUPPORTS_BRANCHING)
  end

  def autocomplete?
    type == 'autocomplete'
  end

  def content?
    type == 'content'
  end

  def upload?
    type == 'upload'
  end

  def multiupload?
    type == 'multiupload'
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

  def max_files
    metadata.max_files.presence || '0'
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
