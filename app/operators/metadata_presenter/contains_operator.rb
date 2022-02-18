module MetadataPresenter
  class ContainsOperator < BaseOperator
    def evaluate?
      @actual == @expected
    end

    def evaluate_collection?
      Array(@expected).include?(@actual)
    end
  end
end
