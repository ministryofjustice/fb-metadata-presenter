class MetadataPresenter::Metadata
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :metadata

  def initialize(metadata, editor: false)
    @metadata = OpenStruct.new(metadata)
    @editor = editor
  end

  def to_json
    self.to_h.to_json
  end

  def id
    metadata._id
  end

  def type
    metadata._type
  end

  def respond_to_missing?(method_name, include_private = false)
    metadata.respond_to?(method_name)
  end

  def method_missing(method_name, *args, &block)
    value = metadata.send(method_name, *args, &block)
    value.blank? && editor? ? MetadataPresenter::DefaultText[method_name] : value
  end

  def editor?
    @editor.present?
  end
end
