module MetadataPresenter
  class FileUploader
    include ActiveModel::Model
    attr_accessor :session, :page_answers, :component, :adapter

    def upload
      UploadedFile.new(file: upload_file, component: component)
    end

    def upload_file
      adapter.new(
        session: session,
        file_details: page_answers.send(component.id),
        allowed_file_types: component.validation['accept']
      ).call
    end
  end
end
