module MetadataPresenter
  class SavedForm
    include ActiveModel::Model

    attr_accessor :email,
                  :secret_question,
                  :secret_answer

    def initialize; end
  end
end
