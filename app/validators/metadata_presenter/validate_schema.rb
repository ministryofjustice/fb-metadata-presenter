class SchemaNotFoundError < StandardError
end

class MetadataPresenter::ValidateSchema
  class << self
    def before(controller)
      return unless controller.request.post?

      validate(controller.request.params, 'request.service')

      metadata = controller.request.params['metadata']
      Array(metadata['pages']).each do |page|
        validate(page, page['_type'])
      end
    rescue JSON::Schema::ValidationError, JSON::Schema::SchemaError, SchemaNotFoundError => e
      controller.render(
        json: ErrorsSerializer.new(message: e.message).attributes,
        status: :unprocessable_entity
      )
    end

    def validate(metadata, schema_name)
      schema = JSON::Validator.schema_for_uri(schema_name)&.schema || find(schema_name)
      JSON::Validator.validate!(schema, metadata)
    end

    def find(schema_name)
      schema_file = schema_name.gsub('.', '/')
      schema = JSON.parse(
        File.read(
          File.join(
            Rails.application.config.schemas_directory, "#{schema_file}.json"
          )
        )
      )
      jschema = JSON::Schema.new(schema, Addressable::URI.parse(schema['_name']))
      JSON::Validator.add_schema(jschema)
      JSON::Validator.schema_for_uri(schema_name).schema
    rescue Errno::ENOENT
      raise SchemaNotFoundError.new("Schema not found => #{schema_name}")
    end
  end
end
