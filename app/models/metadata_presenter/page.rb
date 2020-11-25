class MetadataPresenter::Page < MetadataPresenter::Metadata
  def ==(other)
    id == other.id if other.respond_to? :id
  end

  def components
    metadata.components&.map do |component|
      MetadataPresenter::Component.new(component)
    end
  end

  def to_partial_path
    type.gsub('.', '/')
  end
end
