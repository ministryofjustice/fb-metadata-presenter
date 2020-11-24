class MetadataPresenter::Page < MetadataPresenter::Metadata
  def ==(other)
    id == other.id
  end

  def components
    metadata.components&.map do |component|
      MetadataPresenter::Component.new(component)
    end
  end

  def template
    type.gsub('.', '/')
  end
end
