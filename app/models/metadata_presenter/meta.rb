class MetadataPresenter::Meta < MetadataPresenter::Metadata
  def items
    metadata.items.map do |item|
      MetadataPresenter::MetaItem.new(item)
    end
  end
end
