module MetadataPresenter
  module TestHelpers
    def service
      MetadataPresenter::Service.new(service_metadata)
    end

    def fixtures_directory
      @_fixtures_directory ||=
        Pathname.new(MetadataPresenter::Engine.root.join('fixtures'))
    end

    def service_metadata
      metadata_fixture(:version)
    end

    def metadata_fixture(fixture_name)
      JSON.parse(File.read(fixtures_directory.join("#{fixture_name}.json")))
    end
  end
end
