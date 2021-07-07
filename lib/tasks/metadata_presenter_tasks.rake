require 'metadata_presenter/test_helpers'

namespace :metadata do
  include MetadataPresenter::TestHelpers

  desc 'Represent the flow objects in human readable form'
  task flow: :environment do
    require 'ruby-graphviz'
    metadata = ENV['SERVICE_METADATA'] || metadata_fixture('branching')
    service = MetadataPresenter::Service.new(metadata)

    graph = MetadataPresenter::Graph.new(service)

    graph.draw.generate_image
    puts "Generated file #{graph.filename}"
    system("open #{graph.filename}")
  end
end

module MetadataPresenter
  class Graph
    attr_reader :service, :filename, :nodes

    delegate :metadata, :start_page, :find_page_by_uuid, :service_slug, to: :service

    def initialize(service)
      @service = service
      @graphviz = GraphViz.new(:G, type: :digraph)
      @filename = Rails.root.join('tmp', "#{service_slug}.png")
      @nodes = {}
    end

    def draw
      draw_nodes
      draw_edges

      self
    end

    def generate_image
      @graphviz.output(png: filename)
    end

    private

    def draw_nodes
      flow.each do |id, _value|
        flow_object = service.flow_object(id)

        if flow_object.branch?
          full_description = flow_object.conditions.map.each_with_index do |condition, _index|
            condition.criterias.map { |criteria|
              criteria.service = service

              "#{criteria.criteria_component.humanised_title} #{criteria.operator} #{criteria.field_label}"
            }.join(" #{condition.condition_type} ")
          end
          nodes[id] = @graphviz.add_nodes(full_description.flatten.join(' / '))
        else
          current_page = find_page_by_uuid(id)
          nodes[id] = @graphviz.add_nodes(current_page.url)
        end
      end
    end

    def draw_edges
      flow.each do |id, _value|
        flow_object = service.flow_object(id)
        current_node = nodes[id]
        node_next = nodes[flow_object.default_next]

        if flow_object.branch?
          @graphviz.add_edges(current_node, node_next, label: 'Conditions are not met', labelfontsize: 8) if node_next

          flow_object.group_by_page.each do |page_uuid, _conditions|
            conditions_node = nodes[page_uuid]
            @graphviz.add_edges(current_node, conditions_node, label: 'Conditions are met', labelfontsize: 8) if conditions_node
          end
        elsif node_next
          @graphviz.add_edges(current_node, node_next)
        end
      end
    end

    def flow
      service.flow
    end
  end
end
