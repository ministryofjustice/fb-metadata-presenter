module MetadataPresenter
  class BaseOperator
    attr_reader :actual, :expected

    def initialize(actual, expected)
      @actual = actual
      @expected = expected
    end
  end
end
