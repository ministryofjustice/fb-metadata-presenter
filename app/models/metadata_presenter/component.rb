class MetadataPresenter::Component < MetadataPresenter::Metadata
  def to_partial_path
    "component/#{type}"
  end
end
