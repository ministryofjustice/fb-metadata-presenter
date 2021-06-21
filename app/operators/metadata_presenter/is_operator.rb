module MetadataPresenter
  class IsOperator < BaseOperator
    def evaluate?
      @actual == @expected
    end
  end
end
