class MetadataPresenter::Metadata
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

  def method_missing(method, *args, &block)
    metadata.send(method, *args, &block)
  end
end
