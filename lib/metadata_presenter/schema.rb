require 'json-schema'

class InvalidMetadataError < StandardError
end

class MetadataPresenter::Schema
  attr_reader :metadata

  def initialize(metadata)
    @metadata = metadata
  end

  def type
    unless metadata['_type']
      raise InvalidMetadataError.new('Missing metadata _type property')
    end
    metadata['_type']
  end

  def validate
    service_schema = find
    JSON::Validator.validate!(service_schema, metadata)
    puts '*********************************************************'
    puts 'Schemas are valid!! #winning'
    puts '*********************************************************'
  end

  def find
    schemas_directory = File.join(File.dirname(__FILE__), '..', '..', 'schemas')
    schema_file = type.gsub('.', '/')
    schema = File.read(File.join(schemas_directory, "#{schema_file}.json"))
    JSON.parse(schema)
  rescue Errno::ENOENT
    raise InvalidMetadataError.new("No such schema => #{type}")
  end
end
