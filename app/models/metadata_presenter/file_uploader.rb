module MetadataPresenter
  class FileUploader
    include ActiveModel::Model
    attr_accessor :session, :page_answers, :component, :adapter, :count

    def upload
      UploadedFile.new(file: upload_file(count), component:)
    end

    def upload_file(count)
      return {} if file_details.blank?

      adapter.new(
        session:,
        file_details:,
        allowed_file_types: component.validation['accept'],
        count:
      ).call
    end

    def file_details
      page_answers.send(component.id)
    end
  end
end
