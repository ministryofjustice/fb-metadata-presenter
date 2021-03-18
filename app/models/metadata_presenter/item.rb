class MetadataPresenter::Item < MetadataPresenter::Metadata
  def id
    label
  end

  def name
    label
  end

  def description
    hint
  end
end
