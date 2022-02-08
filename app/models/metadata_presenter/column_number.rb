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
        # Even though we are associating the column number to a specific flow object
        # in the Coordinates model we do not use column_number + 1 as we are
        # updating the position for the Spacers that exist for a branch which
        # are always in the same column as the branch object itself.
        coordinates.set_branch_spacers_column(uuid, column_number)
      end

      column_number
    end

    private

    attr_reader :uuid, :coordinates, :new_column, :service

    def column_number
      @column_number ||= begin
        return last_column if confirmation_page?
        return latest_column if checkanswers_page?

        existing_column || new_column
      end
    end

    def confirmation_page?
      service.confirmation_page&.uuid == uuid
    end

    def checkanswers_page?
      service.checkanswers_page&.uuid == uuid
    end

    def latest_column
      [existing_column, new_column].compact.max
    end

    def last_column
      checkanswers_column.present? ? checkanswers_column + 1 : latest_column
    end

    def checkanswers_column
      @checkanswers_column ||= begin
        return if service.checkanswers_page.blank?

        coordinates.uuid_column(service.checkanswers_page&.uuid)
      end
    end

    def existing_column
      @coordinates.uuid_column(uuid)
    end
  end
end
