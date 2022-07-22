class MetadataPresenter::AutocompleteItem < MetadataPresenter::Metadata
  def id
    { text: text, value: value }.to_json
  end

  def name
    text
  end
end
