module MetadataPresenter
  class Condition < MetadataPresenter::Metadata
    def ==(other)
      metadata.to_h.deep_symbolize_keys == other.metadata.to_h.deep_symbolize_keys
    end

    def criterias
      Array(metadata.criterias).map do |criteria|
        MetadataPresenter::Criteria.new(criteria)
      end
    end
  end
end
