module MetadataPresenter
  class OfflineUploadAdapter
    include ActiveModel::Model
    attr_accessor :session, :file_details, :allowed_file_types

    def call
      {}
    end
  end
end
