module MetadataPresenter
  class SaveAndReturnController < EngineController
    helper_method :secret_questions

    def show
      @saved_form = SavedForm.new
    end

    def create
    end

    def secret_questions
      [
        OpenStruct.new(id: 1, name: I18n.t('presenter.save_and_return.secret_questions.one')),
        OpenStruct.new(id: 2, name: I18n.t('presenter.save_and_return.secret_questions.two')),
        OpenStruct.new(id: 3, name: I18n.t('presenter.save_and_return.secret_questions.three'))
      ]
    end
  end
end