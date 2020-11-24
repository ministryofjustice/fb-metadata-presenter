class MetadataPresenter::Component < MetadataPresenter::Metadata
  include ActiveModel::Conversion

  def to_partial_path
    "component/#{type}"
  end
end
