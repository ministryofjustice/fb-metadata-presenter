module MetadataPresenter
  class ServiceController < EngineController
    def start
      @page = service.start_page
      render template: @page.template
    end
  end
end
