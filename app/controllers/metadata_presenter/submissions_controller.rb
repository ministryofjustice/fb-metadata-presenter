module MetadataPresenter
  class SubmissionsController < EngineController
    def create
      @page = service.confirmation_page

      if @page
        redirect_to_page @page.url
      else
        not_found
      end
    end
  end
end
