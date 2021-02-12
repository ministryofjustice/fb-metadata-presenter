class MetadataPresenter::Component < MetadataPresenter::Metadata
  def to_partial_path
    "metadata_presenter/component/#{type}"
  end

  def humanised_title
    self.label || self.legend
  end

  def items
    metadata.items.map do |item|
      OpenStruct.new(
        id: item['label'],
        name: item['label'],
        description: item['hint']
      )
    end
  end
end
