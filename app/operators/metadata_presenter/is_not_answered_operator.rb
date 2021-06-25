module MetadataPresenter
  class IsNotAnsweredOperator < BaseOperator
    def evaluate?
      expected.blank?
    end
  end
end
