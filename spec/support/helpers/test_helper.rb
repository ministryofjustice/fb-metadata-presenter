module TestHelper
  def service
    MetadataPresenter::Service.new(service_metadata)
  end

  def service_metadata
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.root.join('spec', 'fixtures', 'version.json')
      )
    )
  end
end
