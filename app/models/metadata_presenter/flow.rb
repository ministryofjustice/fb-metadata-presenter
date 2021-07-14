module MetadataPresenter
  class Flow < MetadataPresenter::Metadata
    def branch?
      type == 'flow.branch'
    end

    def default_next
      metadata['next']['default']
    end

    def conditionals
      Array(metadata['next']['conditionals']).map do |conditional_metadata|
        Conditional.new(conditional_metadata)
      end
    end

    def group_by_page
      conditionals.group_by(&:next)
    end
  end
end
