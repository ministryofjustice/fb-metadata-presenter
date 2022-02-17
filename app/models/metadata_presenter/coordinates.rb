module MetadataPresenter
  class Coordinates
    include BranchDestinations

    def initialize(service)
      @service = service
      @positions = setup_positions
      @branch_spacers = setup_branch_spacers
    end

    attr_reader :positions, :branch_spacers

    def set_column(uuid, number)
      positions[uuid][:column] = number
    end

    def set_row(uuid, number)
      positions[uuid][:row] = number
    end

    def uuid_column(uuid)
      positions[uuid][:column]
    end

    def uuid_row(uuid)
      positions[uuid][:row]
    end

    def uuid_at_position(column, row)
      positions.find do |uuid, position|
        if position[:column] == column && position[:row] == row
          return uuid
        end
      end
    end

    def positions_in_column(column_number)
      positions.select { |_, position| position[:column] == column_number }
    end

    def set_branch_spacers_column(branch_uuid, column)
      branch_spacers[branch_uuid].each do |position|
        position[:column] = column
      end
    end

    # The first conditional will always attempt to draw an arrow on the same row
    # as the branch object.
    # Each following conditional needs to have a spacers in order for the frontend
    # to draw an arrow therefore we increment the row number from the branches
    # calculated starting row
    def set_branch_spacers_row(branch_uuid, starting_row)
      branch_spacers[branch_uuid].each.with_index(starting_row) do |position, row|
        position[:row] = row
      end
    end

    private

    attr_reader :service
    attr_writer :positions, :branch_spacers

    def setup_positions
      service.flow.keys.index_with { |_uuid| { row: nil, column: nil } }
    end

    # This also takes into account the 'OR' expressions which
    # need an additional line for an arrow.
    def setup_branch_spacers
      service.branches.each.with_object({}) do |branch, hash|
        hash[branch.uuid] = initial_spacer(branch)
      end
    end

    def initial_spacer(branch)
      destinations = exiting_destinations_from_branch(branch).map do |uuid|
        { uuid: uuid, row: nil, column: nil }
      end
      has_or_conditionals?(branch) ? destinations.uniq : destinations
    end
  end
end
