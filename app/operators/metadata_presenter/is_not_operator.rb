module MetadataPresenter
  class IsNotOperator < BaseOperator
    def evaluate?
      @actual != @expected
    end

    def evaluate_collection?
      Array(@expected).exclude?(@actual)
    end
  end
end
