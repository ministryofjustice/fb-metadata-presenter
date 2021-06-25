module MetadataPresenter
  class BaseOperator
    attr_reader :actual, :expected

    def initialize(actual, expected)
      @actual = actual
      @expected = expected
    end

    def evaluate?
      raise NotImplementedError
    end

    # Method signature for collection components (a.k.a checkboxes)
    #
    def evaluate_collection?
      evaluate?
    end
  end
end
