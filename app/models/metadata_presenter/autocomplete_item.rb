class MetadataPresenter::AutocompleteItem < MetadataPresenter::Metadata
  def id
    { text:, value: }.to_json
  end

  def name
    text
  end
end
