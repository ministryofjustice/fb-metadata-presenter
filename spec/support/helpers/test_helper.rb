module TestHelper
  def service
    MetadataPresenter::Service.new(service_metadata)
  end

  def service_metadata
    metadata_fixture(:version)
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.root.join('spec', 'fixtures', 'version.json')
      )
    )
  end

  def metadata_fixture(fixture_name)
    JSON.parse(
      File.read(
        MetadataPresenter::Engine.root.join(
          'spec',
          'fixtures',
          "#{fixture_name}.json"
        )
      )
    )
  end
end
