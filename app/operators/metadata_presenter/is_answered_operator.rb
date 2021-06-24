module MetadataPresenter
  class IsAnsweredOperator < BaseOperator
    def evaluate?
      expected.present?
    end
  end
end
