module MetadataPresenter
  class CatchAllValidator < BaseValidator
    ERROR_NAME_PREFIX = 'error.'.freeze

    # NOTE: generic errors in other components can be implemented
    # by introducing new case branching if neccessary.
    def invalid_answer?
      case component.type
      when 'upload', 'multiupload'
        upload_user_answer&.error_name.to_s.start_with?(ERROR_NAME_PREFIX)
      else
        false
      end
    end

    private

    def upload_user_answer
      page_answers.uploaded_files.find do |uploaded_file|
        component.id == uploaded_file.component.id
      end
    end
  end
end
