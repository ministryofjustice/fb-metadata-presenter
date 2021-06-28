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

    def group_by_page
      conditions.group_by(&:next)
    end
  end
end
