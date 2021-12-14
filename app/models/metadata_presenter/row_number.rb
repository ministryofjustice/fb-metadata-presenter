module MetadataPresenter
  class RowNumber
    def initialize(uuid:, route:, current_row:, coordinates:, service:)
      @uuid = uuid
      @route = route
      @current_row = current_row
      @coordinates = coordinates
      @service = service
    end

    ROW_ZERO = 0

    def number
      if service.flow_object(uuid).branch?
        coordinates.set_branch_spacers_row(uuid, calculated_row)
      end

      calculated_row
    end

    private

    attr_reader :uuid, :route, :current_row, :coordinates, :service

    def calculated_row
      @calculated_row ||= begin
        return route.row if first_row? && existing_row.nil?

        return ROW_ZERO if place_on_row_zero?

        existing_row || [current_row, potential_row].compact.max
      end
    end

    def existing_row
      @existing_row ||= coordinates.uuid_row(uuid)
    end

    def potential_row
      return if branches_in_column.empty?

      row_numbers = branches_in_column.map do |uuid, _|
        coordinates.branch_spacers[uuid].map { |position| position[:row] }
      end
      row_numbers.flatten.max + 1
    end

    def first_row?
      @first_row ||= route.row.zero?
    end

    def branches_in_column
      @branches_in_column ||= coordinates.positions_in_column(uuid_column).select do |key, position|
        next if uuid == key || position[:row].blank?

        service.flow_object(key).branch?
      end
    end

    def uuid_column
      @uuid_column ||= coordinates.uuid_column(uuid)
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
