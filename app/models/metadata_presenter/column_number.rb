module MetadataPresenter
  class ColumnNumber
    def initialize(uuid:, coordinates:, new_column:)
      @uuid = uuid
      @coordinates = coordinates
      @new_column = new_column
    end

    def number
      [existing_column, new_column].compact.max
    end

    private

    attr_reader :uuid, :coordinates, :new_column

    def existing_column
      @coordinates.uuid_column(uuid)
    end
  end
end
