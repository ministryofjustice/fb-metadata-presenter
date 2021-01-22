class MetadataPresenter::Component < MetadataPresenter::Metadata
  def to_partial_path
    "metadata_presenter/component/#{type}"
  end
end
