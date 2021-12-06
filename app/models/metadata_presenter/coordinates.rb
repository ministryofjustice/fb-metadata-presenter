module MetadataPresenter
  class Coordinates
    def initialize(service)
      @service = service
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

    private

    attr_reader :service
    attr_writer :positions

    def setup_positions
      service.flow.keys.index_with { |_uuid| { row: nil, column: nil } }
    end
  end
end
