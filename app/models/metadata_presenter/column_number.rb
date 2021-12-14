module MetadataPresenter
  class ColumnNumber
    def initialize(uuid:, coordinates:, new_column:, service:)
      @uuid = uuid
      @coordinates = coordinates
      @new_column = new_column
      @service = service
    end

    def number
      if use_latest_column?
        [existing_column, new_column].compact.max
      else
        existing_column || new_column
      end
    end

    private

    attr_reader :uuid, :coordinates, :new_column, :service

    def use_latest_column?
      cya_or_confirmation_page?
    end

    def cya_or_confirmation_page?
      [service.checkanswers_page.uuid, service.confirmation_page.uuid].include?(uuid)
    end

    def existing_column
      @coordinates.uuid_column(uuid)
    end
  end
end
