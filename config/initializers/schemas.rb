Rails.application.config.schemas_directory = MetadataPresenter::Engine.root.join('schemas')

Rails.logger.info('Loading all schemas')
schemas = Dir.glob("#{Rails.application.config.schemas_directory}/*/**")
schemas.each do |schema_file|
  schema = JSON.parse(File.read(schema_file))

  Rails.logger.info(schema['_name'])
  jschema = JSON::Schema.new(schema, Addressable::URI.parse(schema['_name']))
  JSON::Validator.add_schema(jschema)
end

Rails.logger.info("Total loaded schemas => #{JSON::Validator.schemas.count}")
