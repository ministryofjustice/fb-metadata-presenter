module MetadataPresenter
  class RowNumber
    def initialize(uuid:, route:, coordinates:, service:)
      @uuid = uuid
      @route = route
      @coordinates = coordinates
      @service = service
    end

    def number
      existing_row || route.row
    end

    private

    attr_reader :uuid, :route, :coordinates, :service

    def existing_row
      coordinates[uuid][:row]
    end
  end
end
