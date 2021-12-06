module MetadataPresenter
  class Spacer < OpenStruct
    def type
      'flow.spacer'
    end
  end

  class Pointer < OpenStruct
    def type
      'flow.pointer'
    end
  end

  class Grid
    attr_reader :start_from

    def initialize(service, start_from: nil, main_flow: [])
      @service = service
      @start_from = start_from
      @main_flow = main_flow
      @ordered = []
      @routes = []
      @traversed = []
      @coordinates = MetadataPresenter::Coordinates.new(service)
    end

    ROW_ZERO = 0

    def build
      return @ordered unless @ordered.empty?

      @ordered = make_grid
      set_column_numbers
      set_row_numbers
      add_by_coordinates
      insert_expression_spacers
      trim_pointers unless main_flow.empty?
      trim_spacers

      @ordered = @ordered.reject(&:empty?)
    end

    def ordered_flow
      @ordered_flow ||=
        build.flatten.reject { |obj| obj.is_a?(MetadataPresenter::Spacer) }
    end

    def ordered_pages
      @ordered_pages ||= ordered_flow.reject(&:branch?)
    end

    def flow_uuids
      ordered_flow.map(&:uuid)
    end

    def page_uuids
      ordered_pages.map(&:uuid)
    end

    private

    attr_reader :service, :main_flow
    attr_accessor :ordered, :traversed, :routes, :coordinates

    def route_from_start
      @route_from_start ||=
        MetadataPresenter::Route.new(
          service: service,
          traverse_from: start_from || service.start_page.uuid
        )
    end

    def make_grid
      traverse_all_routes

      max_potential_columns.times.map do
        max_potential_rows.times.map { MetadataPresenter::Spacer.new }
      end
    end

    def max_potential_rows
      @max_potential_rows ||= begin
        destinations_count = service.branches.map do |branch|
          exiting_destinations_from_branch(branch).count
        end
        destinations_count.sum
      end
    end

    def max_potential_columns
      @routes.map { |r| r.column + r.flow_uuids.count }.max + 1
    end

    def traverse_all_routes
      # Always traverse the route from the start_from uuid. Defaulting to the
      # start page of the form unless otherwise specified.
      # Get all the potential routes from any branching points that exist.
      route_from_start.traverse
      @routes.append(route_from_start)
      traversed_routes = route_from_start.routes

      index = 0
      until traversed_routes.empty?
        if index > total_potential_routes
          ActiveSupport::Notifications.instrument(
            'exceeded_total_potential_routes',
            message: 'Exceeded total number of potential routes'
          )
          break
        end

        route = traversed_routes.shift
        @routes.append(route)

        # Every route exiting a branching point needs to be traversed and any
        # additional routes from other branching points collected and then also
        # traversed.
        route.traverse
        traversed_routes |= route.routes

        index += 1
      end
    end

    def set_column_numbers
      @routes.each do |route|
        route.flow_uuids.each.with_index(route.column) do |uuid, new_column|
          existing_column = @coordinates.uuid_column(uuid)
          if existing_column.nil? || new_column > existing_column
            @coordinates.set_column(uuid, new_column)
          end
        end
      end
    end

    def set_row_numbers
      @routes.each do |route|
        next if @traversed.include?(route.traverse_from)

        route.flow_uuids.each do |uuid|
          row_number = MetadataPresenter::RowNumber.new(
            uuid: uuid,
            route: route,
            coordinates: @coordinates,
            service: service
          ).number
          @coordinates.set_row(uuid, row_number)

          update_route_rows(route, uuid)
          @traversed.push(uuid) unless @traversed.include?(uuid)
        end
      end
    end

    # Each Route object has a starting row. Each Route object has no knowledge
    # of other potential routes and pages/branches that may or may not exist in
    # them. The starting row may need to change dependent upon what has been
    # traversed in other routes.
    def update_route_rows(route, uuid)
      flow_object = service.flow_object(uuid)
      if flow_object.branch? && route.row > ROW_ZERO
        destinations = routes_exiting_branch(flow_object)
        destinations.each.with_index(route.row) do |destination_uuid, row|
          @routes.each do |r|
            r.row = row if r.traverse_from == destination_uuid
          end
        end
      end
    end

    def add_by_coordinates
      service.flow.keys.each do |uuid|
        position = coordinates.position(uuid)
        next if detached?(position)

        @ordered[position[:column]][position[:row]] = get_flow_object(uuid)
      end
    end

    def detached?(position)
      position[:row].nil? || position[:column].nil?
    end

    def get_flow_object(uuid)
      # main_flow is always empty if the Grid is _actually_ building the main flow
      return MetadataPresenter::Pointer.new(uuid: uuid) if main_flow.include?(uuid)

      service.flow_object(uuid)
    end

    # A row should end at the first Pointer object it finds.
    # Therefore replace any Pointers after the first one with Spacers.
    def trim_pointers
      max_potential_rows.times do |row|
        first_index_of = first_pointer(row)
        next unless first_index_of

        next_column = first_index_of + 1
        @ordered.drop(next_column).each do |column|
          column[row] = MetadataPresenter::Spacer.new
        end
      end
    end

    def first_pointer(row)
      row_objects = @ordered.map { |column| column[row] }
      row_objects.find_index { |obj| obj.is_a?(MetadataPresenter::Pointer) }
    end

    # Find the very last MetadataPresenter::Flow object in every column and
    # remove any Spacer objects after that.
    def trim_spacers
      @ordered.each_with_index do |column, column_number|
        last_index_of = column.rindex { |item| !item.is_a?(MetadataPresenter::Spacer) }
        trimmed_column = @ordered[column_number][0..last_index_of]

        # We do not need any columns that only contain Spacer objects
        @ordered[column_number] = only_spacers?(trimmed_column) ? [] : trimmed_column
      end
    end

    def only_spacers?(trimmed_column)
      trimmed_column.all? { |item| item.is_a?(MetadataPresenter::Spacer) }
    end

    # Each branch has a certain number of exits that require their own line
    # and arrow. Insert any spacers into the necessary row in the column after
    # the one the branch is located in.
    def insert_expression_spacers
      service.branches.each do |branch|
        position = @coordinates.position(branch.uuid)
        next if detached?(position) # detached branch

        next_column = position[:column] + 1
        uuids = []
        exiting_destinations_from_branch(branch).each.with_index(position[:row]) do |uuid, row|
          if uuids.include?(uuid)
            @ordered[next_column].insert(row, MetadataPresenter::Spacer.new)
          end

          uuids.push(uuid) unless uuids.include?(uuid)
        end
      end
    end

    # The frontend requires that expressions of type 'or' get there own line and
    # arrow. 'and' expression types continue to be grouped together.
    # Return the UUIDs of the destinations exiting a branch and allow duplicates
    # if the expression type is an 'or'.
    def exiting_destinations_from_branch(branch)
      destination_uuids = branch.conditionals.map do |conditional|
        if conditional.type == 'or'
          conditional.expressions.map(&:next)
        else
          conditional.next
        end
      end
      destination_uuids.flatten
    end

    # Any destinations exiting the branch that have not already been traversed.
    def routes_exiting_branch(branch)
      branch.all_destination_uuids.reject { |uuid| @traversed.include?(uuid) }
    end

    # Deliberately not including the default next for each branch as when row
    # zero is created it takes the first available conditional for each branch.
    # The remaining are then used to create route objects. Therefore the total
    # number of remaining routes will be the same as the total of all the branch
    # conditionals.
    # Add 1 additional route as that represents the route_from_start.
    def total_potential_routes
      @total_potential_routes ||=
        service.branches.sum { |branch| branch.conditionals.size } + 1
    end
  end
end
