class MetadataPresenter::Component < MetadataPresenter::Metadata
  def to_partial_path
    "metadata_presenter/component/#{type}"
  end

  def humanised_title
    label || legend
  end

  def items
    Array(metadata.items).map do |item|
      MetadataPresenter::Item.new(item, editor: editor?)
    end
  end

  def content?
    type == 'content'
  end

  def upload?
    type == 'upload'
  end

  def find_item_by_uuid(uuid)
    items.find { |item| item.uuid == uuid }
  end
end
