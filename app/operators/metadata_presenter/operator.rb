module MetadataPresenter
  class NoOperator < StandardError
  end

  class Operator
    attr_reader :operator

    def initialize(operator)
      @operator = operator
    end

    def evaluate(actual, expected)
      klass
        .constantize
        .new(actual, expected)
        .evaluate?
    rescue NameError
      raise NoOperator,
            "Operator '#{operator}' is not implemented. You need to create the class #{klass}"
    end

    def klass
      "MetadataPresenter::#{@operator.capitalize.classify}Operator"
    end
  end
end
