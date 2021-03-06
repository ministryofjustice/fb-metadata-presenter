class MetadataPresenter::Metadata
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_reader :metadata

  def initialize(metadata)
    @metadata = OpenStruct.new(metadata)
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
    metadata.send(method_name, *args, &block)
  end
end
