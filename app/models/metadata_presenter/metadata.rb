class MetadataPresenter::Metadata
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :metadata

  def initialize(metadata, editor: false)
    @metadata = OpenStruct.new(metadata)
    @editor = editor
  end

  def to_json(*_args)
    to_h.to_json
  end

  def uuid
    metadata._uuid
  end

  def id
    metadata._id
  end

  def type
    metadata._type
  end

  def respond_to_missing?(method_name, _include_private = false)
    metadata.respond_to?(method_name)
  end

  def method_missing(method_name, *args, &block)
    value = metadata.send(method_name, *args, &block)
    value.blank? && editor? ? MetadataPresenter::DefaultText.fetch(method_name, value) : value
  end

  def ==(other)
    id == other.id if other.respond_to? :id
  end

  def editor?
    @editor.present?
  end
end
