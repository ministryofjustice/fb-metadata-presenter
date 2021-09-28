module MetadataPresenter
  class Route
    attr_reader :traverse_from
    attr_accessor :flow_uuids, :routes, :row, :column

    def initialize(service:, traverse_from:, row: 0, column: 0)
      @service = service
      @traverse_from = traverse_from
      @row = row
      @column = column
      @routes = []
      @flow_uuids = []
    end

    def traverse
      @flow_uuid = traverse_from

      index = column
      until @flow_uuid.blank?
        if index > service.flow.size
          ActiveSupport::Notifications.instrument(
            'exceeded_total_flow_objects',
            message: 'Exceeded total number of flow objects'
          )
          break
        end

        @flow_uuids.push(@flow_uuid) unless @flow_uuids.include?(@flow_uuid)
        flow_object = service.flow_object(@flow_uuid)

        if flow_object.branch?
          destinations = destination_uuids(flow_object)
          # Take the first conditional destination and follow that until the end
          # of the route.
          @flow_uuid = destinations.shift

          # The remaining conditional destinations and the branch's default next
          # (otherwise) will be the starting point for a new Route object to be
          # traversed.
          # The default behaviour is that the next destination will be on the row
          # below this current route's row. This can be changed under certain
          # conditions in the Grid model.
          # Each of the destinations need to be placed in the column after the
          # current column.
          row_number = row + 1
          column_number = index + 1
          destinations.each do |uuid|
            @routes.push(
              MetadataPresenter::Route.new(
                service: service,
                traverse_from: uuid,
                row: row_number,
                column: column_number
              )
            )
            row_number += 1
          end
        else
          @flow_uuid = flow_object.default_next
        end

        index += 1
      end

      @flow_uuids
    end

    private

    attr_reader :service

    def destination_uuids(flow_object)
      flow_object.conditionals.map(&:next).push(flow_object.default_next)
    end
  end
end
