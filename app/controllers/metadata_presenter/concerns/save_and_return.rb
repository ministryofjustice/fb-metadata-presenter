module MetadataPresenter
  module SaveAndReturn
    extend ActiveSupport::Concern

    included do
      helper_method :page_slug, :label_text
    end

    def page_slug
      if params && params[:page_slug].present?
        return params[:page_slug]
      end
      if session['returning_slug'].present?
        return session['returning_slug']
      end
      if session['saved_form'].present?
        return session['saved_form']['page_slug']
      end

      if params['saved_form'].present?
        params['saved_form']['page_slug']
      end
    end

    def label_text(text)
      "<h2 class='govuk-heading-m'>#{text}</h2>"
    end
  end
end
