module MetadataPresenter
  class Conditional < MetadataPresenter::Metadata
    def ==(other)
      metadata.to_h.deep_symbolize_keys == other.metadata.to_h.deep_symbolize_keys
    end

    def expressions
      Array(metadata.expressions).map do |expression|
        MetadataPresenter::Expression.new(expression)
      end
    end
  end
end
