Rails.application.config.default_metadata_directory = MetadataPresenter::Engine.root.join('default_metadata')

Rails.application.config.default_metadata = {}

Rails.logger.info('Loading default metadata')
default_metadata = Dir.glob("#{Rails.application.config.default_metadata_directory}/*/**")
default_metadata.each do |metadata_file|
  metadata = JSON.parse(File.read(metadata_file))

  key = metadata['_id'] || metadata['_type'] || "#{metadata_file.split('/')[-2]}.#{File.basename(metadata_file, '.*')}"
  Rails.logger.info(key)

  Rails.application.config.default_metadata[key] = metadata
end

Rails.logger.info(
  "Total loaded default metadata => #{Rails.application.config.default_metadata.count}"
)
