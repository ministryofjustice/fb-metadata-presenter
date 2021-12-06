module MetadataPresenter
  class RowNumber
    def initialize(uuid:, route:, coordinates:, service:)
      @uuid = uuid
      @route = route
      @coordinates = coordinates
      @service = service
    end

    def number
      return route.row if first_row? && existing_row.nil?

      return existing_row + number_of_destinations if object_above.branch?

      existing_row
    end

    private

    attr_reader :uuid, :route, :coordinates, :service

    def existing_row
      @existing_row ||= coordinates.uuid_row(uuid) || route.row
    end

    def first_row?
      @first_row ||= route.row.zero?
    end

    def object_above
      @object_above ||=
        service.flow_object(coordinates.uuid_at_position(uuid_column, row_above))
    end

    def number_of_destinations
      # The first destination already exists in the same row as the branching
      # object so we therefore want a number one below the total number of
      # destinations
      object_above.all_destination_uuids.count - 1
    end

    def uuid_by_position
      coordinates.reject { |k, _| k == uuid }.find do |coordinate_uuid, position|
        if position[:column] == uuid_column && position[:row] == row_above
          return coordinate_uuid
        end
      end
    end

    def uuid_column
      @uuid_column ||= coordinates.uuid_column(uuid)
    end

    def row_above
      @row_above ||= route.row - 1
    end
  end
end
