module MetadataPresenter
  class Criteria < MetadataPresenter::Metadata
    def ==(other)
      metadata == other.metadata
    end
  end
end
