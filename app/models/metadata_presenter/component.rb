class MetadataPresenter::Component
  include ActiveModel::Conversion

  attr_reader :raw_component

  def initialize(raw_component)
    @raw_component = raw_component
  end

  def id
    raw_component['_id']
  end

  def type
    raw_component['_type']
  end

  def hint
    raw_component['hint']
  end

  def label
    raw_component['label']
  end

  def label_summary
    raw_component['label_summary']
  end

  def name
    raw_component['name']
  end

  def to_partial_path
    "component/#{raw_component['_type']}"
  end
end
