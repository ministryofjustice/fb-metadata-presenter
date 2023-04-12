module MetadataPresenter
  class ResumeForm
    include ActiveModel::Model

    attr_accessor :secret_question,
                  :secret_answer,
                  :recorded_answer

    validates_with SecretAnswerValidator

    def initialize(secret_question)
      self.secret_question = secret_question
    end
  end
end
