module TestHelper
  def service
    MetadataPresenter::Service.new(service_metadata)
  end

  def service_metadata
    metadata_fixture(:version)
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.fixtures_directory.join('version.json')
      )
    )
  end

  def metadata_fixture(fixture_name)
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.fixtures_directory.join("#{fixture_name}.json")
      )
    )
  end
end
