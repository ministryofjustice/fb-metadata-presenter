module MetadataPresenter
  class Spacer < OpenStruct
  end

  class Grid
    def initialize(service)
      @service = service
      @ordered = []
      @routes = []
      @traversed = []
      @coordinates = setup_coordinates
    end

    ROW_ZERO = 0

    def build
      @ordered = make_grid
      add_columns
      add_rows
      add_by_coordinates
      trim_spacers
      insert_expression_spacers

      @ordered
    end

    def ordered_flow
      @ordered_flow ||= begin
        flow = @ordered.empty? ? build.flatten : @ordered.flatten
        flow.reject { |obj| obj.is_a?(MetadataPresenter::Spacer) }
      end
    end

    def ordered_pages
      ordered_flow.reject(&:branch?)
    end

    private

    attr_reader :service
    attr_accessor :ordered, :traversed, :routes, :coordinates

    def setup_coordinates
      service.flow.keys.index_with { |_uuid| { row: nil, column: nil } }
    end

    def route_from_start
      @route_from_start ||=
        MetadataPresenter::Route.new(
          service: service,
          traverse_from: service.start_page.uuid
        )
    end

    def make_grid
      traverse_all_routes

      rows = @routes.map(&:row).max
      columns = @routes.map { |r| r.column + r.flow_uuids.count }.max
      columns.times.map { rows.times.map { MetadataPresenter::Spacer.new } }
    end

    def traverse_all_routes
      # Always traverse the route that begins from the start page first and get
      # the potential routes from any branching points that exist.
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

    def add_columns
      @routes.each do |route|
        route.flow_uuids.each.with_index(route.column) do |uuid, column|
          column_number = @coordinates[uuid][:column]
          if column_number.nil? || column > column_number
            @coordinates[uuid][:column] = column
          end
        end
      end
    end

    def add_rows
      @routes.each do |route|
        route.flow_uuids.each do |uuid|
          next if @traversed.include?(uuid)

          @coordinates[uuid][:row] = route.row if @coordinates[uuid][:row].nil?

          update_route_rows(route, uuid)
          @traversed.push(uuid)
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
      @coordinates.each do |uuid, position|
        # If row and column are nil then the object is detached
        next if position[:row].nil? || position[:column].nil?

        flow_object = service.flow_object(uuid)
        @ordered[position[:column]][position[:row]] = flow_object
      end
    end

    # Find the very last MetadataPresenter::Flow object in every column and
    # remove any Spacer objects after that.
    def trim_spacers
      @ordered.each_with_index do |column, index|
        last_index_of = column.rindex { |item| item.is_a?(MetadataPresenter::Flow) }
        @ordered[index] = @ordered[index][0..last_index_of]
      end
    end

    # Each branch has a certain number of exits that require their own line
    # and arrow. Insert any spacers into the necessary row in the column after
    # the one the branch is located in.
    def insert_expression_spacers
      service.branches.each do |branch|
        position = @coordinates[branch.uuid]
        next if position[:row].nil? || position[:column].nil? # detached branch

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
