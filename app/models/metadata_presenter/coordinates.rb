module MetadataPresenter
  class Coordinates
    def initialize(flow)
      @flow = flow
      @positions = setup_positions
    end

    attr_reader :positions

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

    def position(uuid)
      positions[uuid]
    end

    def positions_in_column(column_number)
      positions.select { |_, position| position[:column] == column_number }
    end

    private

    attr_reader :flow
    attr_writer :positions

    def setup_positions
      flow.keys.index_with { |_uuid| { row: nil, column: nil } }
    end
  end
end
