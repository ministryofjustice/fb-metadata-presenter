module MetadataPresenter
  class Flow < MetadataPresenter::Metadata
    def branch?
      type == 'branch'
    end

    def default_next
      metadata['next']['default']
    end

    def conditions
      Array(metadata['next']['conditions']).map do |condition_metadata|
        Condition.new(condition_metadata)
      end
    end
  end
end
