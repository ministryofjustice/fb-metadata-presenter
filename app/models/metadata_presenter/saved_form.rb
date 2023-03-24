module MetadataPresenter
  class SavedForm
    include ActiveModel::Model

    attr_accessor :email,
                  :secret_question,
                  :secret_answer

    def initialize
    end

    def email
    end

    def secret_question
    end

    def secret_answer
    end
  end
end