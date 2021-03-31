class MetadataPresenter::Item < MetadataPresenter::Metadata
  def name
    label
  end

  def description
    hint
  end
end
