class ServiceMetadataNotFoundError < StandardError
end

fixture = MetadataPresenter::Engine.root.join('fixtures', 'version.json')

if File.exist?(fixture)
  Rails.configuration.service_metadata = JSON.parse(File.read(fixture))
else
  raise ServiceMetadataNotFoundError, "Failed to load #{File.expand_path(fixture)} but service metadata did not exist"
end
