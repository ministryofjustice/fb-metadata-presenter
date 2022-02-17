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

        existing_row || [current_row, potential_row, branch_spacer_row].compact.max
      end
    end

    def existing_row
      @existing_row ||= coordinates.uuid_row(uuid)
    end

    # This looks for any branches in the current column and checks that there is
    # enough space for the any branch conditionals before returning a row number.
    def potential_row
      return if branches_in_column.empty?

      row_numbers = branches_in_column.map do |branch_uuid, _|
        coordinates.branch_spacers[branch_uuid].map { |position| position[:row] }
      end
      row_numbers.flatten.max + 1
    end

    # This looks at the previous column and finds any branches that link to the
    # current object. If any are found it checks for rows numbers that relate
    # to the current objects UUID in the branch spacers hash and defaults to
    # returning the highest row number.
    def branch_spacer_row
      return if spacers_for_current_object.empty?

      spacers_for_current_object.flatten.map { |position| position[:row] }.max
    end

    def first_row?
      @first_row ||= route.row.zero?
    end

    def branches_in_column
      @branches_in_column ||= branches(uuid_column)
    end

    def branches_in_previous_column
      @branches_in_previous_column ||= branches(uuid_column - 1)
    end

    def branches(column_number)
      coordinates.positions_in_column(column_number).select do |key, position|
        next if uuid == key || position[:row].blank?

        service.flow_object(key).branch?
      end
    end

    def spacers_for_current_object
      @spacers_for_current_object ||= begin
        spacer_positions = branches_in_previous_column.select do |key, _|
          coordinates.branch_spacers[key]
        end

        current_object_spacers = spacer_positions.map do |branch_uuid, _|
          coordinates.branch_spacers[branch_uuid].select { |branch_spacer| branch_spacer[:uuid] == uuid }
        end
        current_object_spacers.compact
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
