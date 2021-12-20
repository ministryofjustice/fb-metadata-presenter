module MetadataPresenter
  class ColumnNumber
    def initialize(uuid:, coordinates:, new_column:, service:)
      @uuid = uuid
      @coordinates = coordinates
      @new_column = new_column
      @service = service
    end

    def number
      if service.flow_object(uuid).branch?
        coordinates.set_branch_spacers_column(uuid, column_number)
      end

      column_number
    end

    private

    attr_reader :uuid, :coordinates, :new_column, :service

    def column_number
      @column_number ||= begin
        return latest_column if cya_or_confirmation_page?

        existing_column || new_column
      end
    end

    def latest_column
      [existing_column, new_column].compact.max
    end

    def cya_or_confirmation_page?
      [service.checkanswers_page&.uuid, service.confirmation_page&.uuid].include?(uuid)
    end

    def existing_column
      @coordinates.uuid_column(uuid)
    end
  end
end
