module MetadataPresenter
  class RowNumber
    include BranchDestinations

    def initialize(uuid:, route:, current_row:, coordinates:, service:)
      @uuid = uuid
      @route = route
      @current_row = current_row
      @coordinates = coordinates
      @service = service
    end

    ROW_ZERO = 0

    def number
      return route.row if first_row? && existing_row.nil?

      return ROW_ZERO if place_on_row_zero?

      if object_above.branch? && uuid != object_above.uuid
        coordinates.uuid_row(object_above.uuid) + number_of_destinations
      else
        existing_row.nil? ? current_row : [current_row, existing_row].max
      end
    end

    private

    attr_reader :uuid, :route, :current_row, :coordinates, :service

    def existing_row
      @existing_row ||= coordinates.uuid_row(uuid)
    end

    def first_row?
      @first_row ||= route.row.zero?
    end

    def object_above
      @object_above ||=
        service.flow_object(coordinates.uuid_at_position(uuid_column, row_above))
    end

    # Takes into account the 'or' type of conditionals which requires an
    # additional spacer
    def number_of_destinations
      exiting_destinations_from_branch(object_above).count
    end

    def uuid_column
      @uuid_column ||= coordinates.uuid_column(uuid)
    end

    def row_above
      @row_above ||= route.row - 1
    end

    # If an object has already been positioned on row 0 then leave it there.
    # If the object is a checkanswers or confirmation type then always place it
    # on row 0.
    def place_on_row_zero?
      cya_or_confirmation_page? || coordinates.uuid_row(uuid) == ROW_ZERO
    end

    def cya_or_confirmation_page?
      %w[page.checkanswers page.confirmation].include?(
        service.find_page_by_uuid(uuid)&.type
      )
    end
  end
end
