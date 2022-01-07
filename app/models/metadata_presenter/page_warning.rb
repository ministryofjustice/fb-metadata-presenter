module MetadataPresenter
  class PageWarning
    def initialize(page:, main_flow_uuids:)
      @page = page
      @main_flow_uuids = main_flow_uuids
    end

    def show_warning?
      missing? || detached?
    end

    def missing?
      page.blank?
    end

    def detached?
      main_flow_uuids.exclude?(page&.uuid)
    end

    private

    attr_reader :page, :main_flow_uuids
  end
end
