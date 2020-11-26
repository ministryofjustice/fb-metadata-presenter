class MetadataPresenter::Metadata
  include ActiveModel::Conversion

  attr_reader :metadata

  def initialize(metadata)
    @metadata = OpenStruct.new(metadata)
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

  def method_missing(method, *args, &block)
    metadata.send(method, *args, &block)
  end
end
