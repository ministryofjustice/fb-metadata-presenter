module MetadataPresenter
  class IsNotOperator < BaseOperator
    def evaluate?
      @actual != @expected
    end
  end
end
