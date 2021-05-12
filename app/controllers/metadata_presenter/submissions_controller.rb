module MetadataPresenter
  class SubmissionsController < EngineController
    def create
      @page = service.confirmation_page

      if @page
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
  end
end
