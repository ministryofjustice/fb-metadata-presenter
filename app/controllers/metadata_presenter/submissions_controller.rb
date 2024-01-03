module MetadataPresenter
  class SubmissionsController < EngineController
    def create
      @page = service.confirmation_page

      if @page
        if params[:save_for_later_check_answers].present?
          # this flag is sent by the check answers page, and we don't want to submit & validate here
          redirect_to save_path(page_slug: params[:page_slug]) and return
        end

        create_submission
        redirect_to_page @page.url
      else
        not_found
      end
    end

    def create_submission
      # The runner is the only app that sends the submission.
      # and it is not needed on the editor app (editing & previewing).
      # So in the Runner we defined the #create_submission in the parent
      # controller and in the Editor we don't.
      #
      if defined?(super)
        super
      end
    end

    def create_save_and_return_submission(payload)
      # The runner is the only app that sends the save and return submission.
      # and it is not needed on the editor app (editing & previewing).
      # So in the Runner we defined the #create_save_and_return_submission in the parent
      # controller and in the Editor we don't.
      #
      # :nocov:
      if defined?(super)
        super
      end
      # :nocov:
    end
  end
end
