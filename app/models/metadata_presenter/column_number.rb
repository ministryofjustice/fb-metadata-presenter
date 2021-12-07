module MetadataPresenter
  class ColumnNumber
    def initialize(uuid:, coordinates:, new_column:)
      @uuid = uuid
      @coordinates = coordinates
      @new_column = new_column
    end

    def number
      use_new_column? ? new_column : existing_column
    end

    private

    attr_reader :uuid, :coordinates, :new_column

    def use_new_column?
      existing_column.nil? || new_column > existing_column
    end

    def existing_column
      @existing_column ||= @coordinates.uuid_column(uuid)
    end
  end
end
