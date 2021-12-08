module MetadataPresenter
  module BranchDestinations
    # The frontend requires that expressions of type 'or' get there own line and
    # arrow. 'and' expression types continue to be grouped together.
    # Return the UUIDs of the destinations exiting a branch and allow duplicates
    # if the expression type is an 'or'.
    def exiting_destinations_from_branch(branch)
      destination_uuids = branch.conditionals.map do |conditional|
        if conditional.type == 'or'
          conditional.expressions.map { |_| conditional.next }
        else
          conditional.next
        end
      end
      destination_uuids.flatten.push(branch.default_next)
    end
  end
end
