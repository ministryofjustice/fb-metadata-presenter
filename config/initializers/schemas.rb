Rails.application.config.schemas_directory = MetadataPresenter::Engine.root.join('schemas')

Rails.logger.info('Loading all schemas')
schemas = Dir.glob("#{Rails.application.config.schemas_directory}/*/**")
schemas.each do |schema_file|
  schema = JSON.parse(File.read(schema_file))

  Rails.logger.info(schema['_name'])
  jschema = JSON::Schema.new(schema, Addressable::URI.parse(schema['_name']))
  JSON::Validator.add_schema(jschema)

  if schema.key?('definitions')
    schema['definitions'].each do |key, definition|
      definition_key = "#{schema['_name']}.#{key}"
      Rails.logger.info(definition_key)
      jschema = JSON::Schema.new(definition, Addressable::URI.parse(definition_key))
      JSON::Validator.add_schema(jschema)
    end
  end
end

Rails.logger.info("Total loaded schemas => #{JSON::Validator.schemas.count}")
