module MetadataPresenter
  class Route
    attr_reader :traverse_from
    attr_accessor :flow_uuids, :routes, :row, :column, :previous_flow_uuid,
                  :conditional_uuid, :previous_uuids

    def initialize(service:, traverse_from:, row: 0, column: 0,
                   previous_flow_uuid: nil, conditional_uuid: nil)
      @service = service
      @traverse_from = traverse_from
      @row = row
      @column = column
      @previous_flow_uuid = previous_flow_uuid
      @conditional_uuid = conditional_uuid
      @previous_uuids = setup_previous_uuids
      @routes = []
      @flow_uuids = []
    end

    def traverse
      @flow_uuid = traverse_from
      index = column
      previous_uuid = previous_flow_uuid || ''

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
          destinations = branch_destinations(flow_object)
          # Take the first conditional destination and follow that until the end
          # of the route.
          first_conditional = destinations.shift
          set_first_conditional_previous_flow(flow_object.uuid, first_conditional)
          create_destination_routes(
            previous_flow_uuid: flow_object.uuid,
            destinations:,
            row:,
            column: index
          )

          @flow_uuid = first_conditional[:next]
        else
          @flow_uuid = flow_object.default_next
        end

        unless previous_uuids.key?(flow_object.uuid)
          set_previous_flow(uuid: flow_object.uuid, previous_flow_uuid: previous_uuid)
        end
        previous_uuid = flow_object.uuid
        index += 1
      end

      @flow_uuids
    end

    private

    attr_reader :service

    def branch_destinations(flow_object)
      conditionals = flow_object.conditionals.map do |conditional|
        { next: conditional.next, conditional_uuid: conditional.uuid }
      end

      conditionals.push({ next: flow_object.default_next })
      conditionals
    end

    def set_first_conditional_previous_flow(previous_flow_uuid, first_conditional)
      set_previous_flow(
        uuid: first_conditional[:next],
        previous_flow_uuid:,
        conditional_uuid: first_conditional[:conditional_uuid]
      )
    end

    def set_previous_flow(uuid:, previous_flow_uuid:, conditional_uuid: nil)
      previous_uuids[uuid] = {
        previous_flow_uuid:,
        conditional_uuid:
      }
    end

    # The remaining conditional destinations and the branch's default next
    # (otherwise) will be the starting point for a new Route object to be
    # traversed.
    # The default behaviour is that the next destination will be on the row
    # below this current route's row. This can be changed under certain
    # conditions in the Grid model.
    # Each of the destinations need to be placed in the column after the
    # current column.
    def create_destination_routes(previous_flow_uuid:, destinations:, row:, column:)
      row_number = row + 1
      column_number = column + 1
      destinations.each do |destination|
        @routes.push(
          MetadataPresenter::Route.new(
            service:,
            traverse_from: destination[:next],
            previous_flow_uuid:,
            conditional_uuid: destination[:conditional_uuid],
            row: row_number,
            column: column_number
          )
        )
        row_number += 1
      end
    end

    def setup_previous_uuids
      Hash[
        traverse_from,
        {
          previous_flow_uuid:,
          conditional_uuid:
        }
      ]
    end
  end
end
