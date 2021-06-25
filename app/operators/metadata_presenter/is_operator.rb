module MetadataPresenter
  class IsOperator < BaseOperator
    def evaluate?
      @actual == @expected
    end

    def evaluate_collection?
      Array(@expected).include?(@actual)
    end
  end
end
