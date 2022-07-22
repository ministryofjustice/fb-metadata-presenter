class MetadataPresenter::AutocompleteItem < MetadataPresenter::Metadata
  def id
    value
  end

  def name
    text
  end
end
