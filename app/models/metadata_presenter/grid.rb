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

  class Warning < OpenStruct
    def type
      'flow.warning'
    end
  end

  class Grid
    include BranchDestinations
    attr_reader :service, :start_from, :previous_uuids

    def initialize(service, start_from: nil, main_flow: [])
      @service = service
      @start_from = start_from
      @main_flow = main_flow
      @ordered = []
      @routes = []
      @traversed = []
      @coordinates = MetadataPresenter::Coordinates.new(service)
      @previous_uuids = {}
    end

    ROW_ZERO = 0

    def build
      return @ordered unless @ordered.empty?

      @ordered = make_grid
      set_column_numbers
      set_row_numbers
      set_previous_uuids
      add_by_coordinates
      insert_expression_spacers
      trim_pointers unless main_flow.empty? # only used by detached grids
      trim_spacers
      insert_warning if main_flow.empty?

      @ordered = @ordered.reject(&:empty?)
    end

    def ordered_flow
      @ordered_flow ||=
        build.flatten.reject do |obj|
          obj.is_a?(MetadataPresenter::Spacer) || obj.is_a?(MetadataPresenter::Warning)
        end
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

    def show_warning?
      checkanswers_warning.show_warning? || confirmation_warning.show_warning?
    end

    def previous_uuid_for_object(uuid)
      return unless previous_uuids.key?(uuid)

      previous_uuids[uuid][:previous_flow_uuid]
    end

    def conditional_uuid_for_object(uuid)
      return unless previous_uuids.key?(uuid)

      previous_uuids[uuid][:conditional_uuid]
    end

    private

    attr_reader :main_flow
    attr_accessor :ordered, :traversed, :routes, :coordinates
    attr_writer :previous_uuids

    def route_from_start
      @route_from_start ||=
        MetadataPresenter::Route.new(
          service:,
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
        [destinations_count.sum, 1].max # ensure there is always 1 row
      end
    end

    def max_potential_columns
      @routes.map { |r| r.column + r.flow_uuids.count }.max + 1
    end

    def traverse_all_routes
      # Always traverse the route from the start_from uuid. Defaulting to the
      # start page of the form unless otherwise specified.
      # Get all the potential routes from any branching points that exist.
      traversed_uuids = []
      route_from_start.traverse
      @routes.append(route_from_start)
      traversed_uuids.concat(route_from_start.flow_uuids)
      routes_to_traverse = route_from_start.routes
      index = 0
      Rails.logger.info("Total potential routes: #{total_potential_routes}")

      until routes_to_traverse.empty?
        if index > total_potential_routes
          ActiveSupport::Notifications.instrument(
            'exceeded_total_potential_routes',
            message: 'Exceeded total number of potential routes'
          )
          break
        end

        route = routes_to_traverse.shift
        @routes.append(route)

        # Traverse the route and add any nested routes to the list of routes to
        # traverse.
        # If the first flow_uuid in the route has already been traversed, then
        # this route is looping back, so we don't need to traverse the nested routes.
        route.traverse
        unless traversed_uuids.include?(route.flow_uuids.first)
          routes_to_traverse.concat(route.routes)
        end
        traversed_uuids.concat(route.flow_uuids)

        index += 1
      end
      Rails.logger.info("Total routes traversed: #{index}")
    end

    def set_column_numbers
      @routes.each do |route|
        route.flow_uuids.each.with_index(route.column) do |uuid, new_column|
          column_number = MetadataPresenter::ColumnNumber.new(
            uuid:,
            new_column:,
            coordinates: @coordinates,
            service:
          ).number
          @coordinates.set_column(uuid, column_number)
        end
      end
    end

    def set_row_numbers
      @routes.each do |route|
        next if @traversed.include?(route.traverse_from) && appears_later_in_flow?(route)

        current_row = route.row
        route.flow_uuids.each do |uuid|
          row_number = MetadataPresenter::RowNumber.new(
            uuid:,
            route:,
            current_row:,
            coordinates: @coordinates,
            service:
          ).number
          @coordinates.set_row(uuid, row_number)

          update_route_rows(route, uuid)
          @traversed.push(uuid) unless @traversed.include?(uuid)
          current_row = row_number
        end
      end
    end

    # New routes can be linked to later. We need to also traverse these to see
    # if anything should be moved to a different row.
    def appears_later_in_flow?(route)
      @coordinates.uuid_column(route.traverse_from) > route.column
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
      service.flow.each_key do |uuid|
        position = coordinates.positions[uuid]
        next if detached?(position)

        # Update confirmation page column co-ordinate
        column = if confirmation_and_cya_pages_present? && service.confirmation_page.uuid == uuid
                   coordinates.positions[service.checkanswers_page.uuid][:column] + 1
                 else
                   position[:column]
                 end

        row = position[:row]
        insert_spacer(column, row) if occupied?(column, row, uuid)
        @ordered[column][row] = get_flow_object(uuid)
      end
    end

    def detached?(position)
      position[:row].nil? || position[:column].nil?
    end

    def confirmation_and_cya_pages_present?
      service.confirmation_page.present? &&
        service.checkanswers_page.present? &&
        coordinates.positions[service.checkanswers_page.uuid][:column].present?
    end

    def occupied?(column, row, uuid)
      object = @ordered[column][row]
      object.is_a?(MetadataPresenter::Flow) && object.uuid != uuid
    end

    def get_flow_object(uuid)
      # main_flow is always empty if the Grid is _actually_ building the main flow
      return MetadataPresenter::Pointer.new(uuid:) if main_flow.include?(uuid)

      service.flow_object(uuid)
    end

    def trim_pointers
      update_branch_destination_pointers
      trim_to_first_pointer
      update_coordinates
      replace_pointers
    end

    # Since a detached grid is built in the same way as the main flow grid, objects
    # that appear later in the flow are left in their latest position. However
    # for detached grids we want to show a Pointer to that object. This only
    # happens for branch destinations so in those instances we need to replace
    # the Spacers with Pointers.
    def update_branch_destination_pointers
      @ordered.each_with_index do |column, column_number|
        next_column = column_number + 1

        column.each do |flow_object|
          next unless flow_object.branch?

          coordinates.branch_spacers[flow_object.uuid].map do |destination|
            if replace_with_pointer?(next_column, destination[:row], destination[:uuid])
              @ordered[next_column][destination[:row]] = MetadataPresenter::Pointer.new(uuid: destination[:uuid])
            end
          end
        end
      end
    end

    def replace_with_pointer?(column_number, row_number, destination_uuid)
      @ordered[column_number][row_number].is_a?(MetadataPresenter::Spacer) &&
        main_flow.include?(destination_uuid)
    end

    # A row should end at the first Pointer object it finds.
    # Therefore replace any Pointers after the first one with Spacers.
    def trim_to_first_pointer
      max_potential_rows.times do |row|
        index_of_first_pointer = first_pointer(row)
        next unless index_of_first_pointer

        starting_column = index_of_first_pointer + 1
        @ordered.drop(starting_column).each.with_index(starting_column) do |_, column_index|
          @ordered[column_index][row] = MetadataPresenter::Spacer.new
        end
      end
    end

    def first_pointer(row)
      row_objects(row).find_index { |obj| obj.is_a?(MetadataPresenter::Pointer) }
    end

    def row_objects(row)
      @ordered.map { |column| column[row] }
    end

    # It's a shame to have to do this.
    # Once the Pointers have been trimmed back the original positions for each
    # object will no longer be correct so we need to update them.
    # We only really need to do this because we replace Pointers with Spacers
    # later on.
    def update_coordinates
      @ordered.each_with_index do |column, column_number|
        column.each_with_index do |flow_object, row_number|
          next if flow_object.is_a?(MetadataPresenter::Spacer)

          @coordinates.set_column(flow_object.uuid, column_number)
          @coordinates.set_row(flow_object.uuid, row_number)
        end
      end
    end

    def replace_pointers
      @ordered.each_with_index do |column, column_number|
        next if column_number.zero?

        column.each_with_index do |flow_object, row_number|
          next if flow_object.is_a?(MetadataPresenter::Spacer)

          previous_column = column_number - 1
          if replace_with_spacer?(previous_column, column_number, row_number, flow_object.uuid)
            @ordered[column_number][row_number] = MetadataPresenter::Spacer.new
          end
        end
      end
    end

    def replace_with_spacer?(previous_column, current_column, row_number, uuid)
      no_flow_objects?(previous_column, row_number, uuid) ||
        at_different_position?(current_column, row_number, uuid)
    end

    # Unless the destination is the Pointer for a branch in the directly preceeding
    # column, we want to swap Pointers for Spacers if there are no Flow objects
    # in that row.
    def no_flow_objects?(previous_column, row_number, uuid)
      !branch_destination?(uuid, previous_column) &&
        row_objects(row_number).none?(MetadataPresenter::Flow)
    end

    # The object already exists elsewhere in the flow so we can replace the Pointer
    # and let the frontend draw an arrow to that position.
    def at_different_position?(column_number, row_number, uuid)
      @coordinates.uuid_column(uuid) != column_number &&
        @coordinates.uuid_row(uuid) != row_number
    end

    def branch_destination?(uuid, column_number)
      @ordered[column_number].any? do |flow_object|
        next unless flow_object.branch?

        flow_object.all_destination_uuids.include?(uuid)
      end
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
      trimmed_column.all?(MetadataPresenter::Spacer)
    end

    def set_previous_uuids
      @routes.each do |route|
        route.flow_uuids.each do |uuid|
          if previous_uuids[uuid].blank?
            previous_uuids[uuid] = route.previous_uuids[uuid]
          end
        end
      end
    end

    # Each branch has a certain number of exits that require their own line
    # and arrow. When there are 'OR' conditions we need to insert additional
    # spacers into the necessary row in the column after the one the branch is
    # located in.
    # This is done for the column directly after a branching point
    def insert_expression_spacers
      service.branches.each do |branch|
        next if coordinates.uuid_column(branch.uuid).nil?

        next unless has_or_conditionals?(branch)

        previous_uuid = ''
        next_column = coordinates.uuid_column(branch.uuid) + 1
        exiting_destinations_from_branch(branch).each_with_index do |uuid, row|
          insert_spacer(next_column, row) if uuid == previous_uuid
          previous_uuid = uuid
        end
      end
    end

    def insert_spacer(column, row)
      @ordered[column].insert(row, MetadataPresenter::Spacer.new)
    end

    # Include a warning if a service does not have a CYA or Confirmation page in the
    # main flow. The warning should always be in the first row, last column.
    def insert_warning
      @ordered.append([MetadataPresenter::Warning.new]) if show_warning?
    end

    def checkanswers_warning
      MetadataPresenter::PageWarning.new(
        page: service.checkanswers_page,
        main_flow_uuids: flow_uuids
      )
    end

    def confirmation_warning
      MetadataPresenter::PageWarning.new(
        page: service.confirmation_page,
        main_flow_uuids: flow_uuids
      )
    end

    # Any destinations exiting the branch that have not already been traversed.
    # This removes any branch destinations that already exist on other rows. If
    # that is the case then the arrow will flow towards whatever row that object
    # is located.
    def routes_exiting_branch(branch)
      branch.all_destination_uuids.reject { |uuid| @traversed.include?(uuid) }
    end

    # Calculate an upper limit to prevent infinite traversal
    # Not easy to calculate exactly, aiming for a number that is bigger than
    # total possible routes but not too much bigger.
    def total_potential_routes
      total_conditionals = service.branches.sum { |branch| branch.conditionals.size + 1 }
      @total_potential_routes ||= total_conditionals * total_conditionals
    end
  end
end
