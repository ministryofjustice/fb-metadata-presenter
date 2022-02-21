module MetadataPresenter
  class DoesNotContainOperator < BaseOperator
    def evaluate?
      @actual != @expected
    end

    def evaluate_collection?
      Array(@expected).exclude?(@actual)
    end
  end
end
