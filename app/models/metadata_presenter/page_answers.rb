module MetadataPresenter
  class PageAnswers
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActionView::Helpers
    attr_reader :page, :answers, :uploaded_files, :autocomplete_items
    attr_accessor :count

    def initialize(page, answers, autocomplete_items = nil)
      @page = page
      @answers = answers
      @autocomplete_items = autocomplete_items
      @uploaded_files = []
    end

    def validate_answers
      ValidateAnswers.new(self, components:, autocomplete_items:).valid?
    end

    delegate :components, to: :page

    def respond_to_missing?(method_name, _include_private = false)
      method_name.to_s.in?(components.map(&:id))
    end

    def method_missing(method_name, *_args)
      component = components.find { |c| c.id == method_name.to_s }
      if component && component.type == 'date'
        date_answer(component.id)
      elsif component && component.type == 'upload'
        upload_answer(component.id, count)
      elsif component && component.type == 'multiupload'
        answer_object = multiupload_answer(component.id, count)
        answer_object.to_h if answer_object.present?
      elsif component && component.type == 'checkboxes'
        answers[method_name.to_s].to_a
      elsif component && component.type == 'address'
        address_answer(method_name.to_s)
      else
        sanitize(answers[method_name.to_s])
      end
    end

    private

    def upload_answer(component_id, _count)
      file_details = answers[component_id.to_s]

      return {} unless file_details

      case file_details
      when ActionController::Parameters
        unless file_details.permitted?
          Rails.logger.warn("[PageAnswers#upload_answer] Permitting unfiltered params in component `#{component_id}`")
          file_details.permit!
        end

        file_details.merge(
          'original_filename' => sanitize_filename(file_details['original_filename'])
        )
      when Hash
        file_details.merge(
          'original_filename' => sanitize_filename(file_details['original_filename'])
        )
      else
        {
          'original_filename' => sanitize_filename(file_details.original_filename),
          'content_type' => file_details.content_type,
          'tempfile' => file_details.tempfile.path.to_s
        }
      end
    end

    def multiupload_answer(component_id, _count)
      file_details = answers[component_id.to_s] unless answers.is_a?(MetadataPresenter::MultiUploadAnswer)
      return nil if file_details.nil? && answers.nil?

      if file_details.is_a?(Hash)
        # when referencing a single previous answer but no incoming new answer
        presentable = MetadataPresenter::MultiUploadAnswer.new
        presentable.key = component_id.to_s
        presentable.previous_answers = [file_details]
        return presentable
      end

      if file_details.is_a?(Array)
        # when referencing multiple previous answers but no incoming new answer
        presentable = MetadataPresenter::MultiUploadAnswer.new
        presentable.key = component_id.to_s
        presentable.previous_answers = file_details.reject { |f| f['original_filename'].blank? }
        return presentable
      end

      if answers.blank?
        return nil
      end

      if answers.is_a?(Hash) # rendering only existing answers
        return if answers[component_id].blank?

        if answers[component_id].is_a?(Array)
          answers[component_id].each { |answer| answer['original_filename'] = sanitize_filename(answer['original_filename']) }
        end

        answers[component_id] = answers[component_id].reject { |a| a['original_filename'].blank? }
        return answers
      end

      return answers if answers.incoming_answer.blank?

      # uploading a new answer, this method will be called during multiple render operations
      if answers.incoming_answer.is_a?(ActionController::Parameters)
        answers.incoming_answer[component_id].original_filename = sanitize_filename(answers.incoming_answer[component_id].original_filename)
      end

      if answers.incoming_answer.is_a?(Hash)
        answers.incoming_answer['original_filename'] = sanitize_filename(answers.incoming_answer['original_filename'])
      end

      if answers.incoming_answer[component_id].is_a?(ActionDispatch::Http::UploadedFile)
        answers.incoming_answer = {
          'original_filename' => sanitize_filename(answers.incoming_answer[component_id].original_filename),
          'content_type' => answers.incoming_answer[component_id].content_type,
          'tempfile' => answers.incoming_answer[component_id].tempfile.path.to_s,
          'uuid' => SecureRandom.uuid
        }
      end

      answers
    end

    def date_answer(component_id)
      date = raw_date_answer(component_id)

      MetadataPresenter::DateField.new(day: date[0], month: date[1], year: date[2])
    end

    def raw_date_answer(component_id)
      [
        GOVUKDesignSystemFormBuilder::Elements::Date::SEGMENTS[:day],
        GOVUKDesignSystemFormBuilder::Elements::Date::SEGMENTS[:month],
        GOVUKDesignSystemFormBuilder::Elements::Date::SEGMENTS[:year]
      ].map do |segment|
        sanitize(answers["#{component_id}(#{segment})"])
      end
    end

    def sanitize_filename(answer)
      sanitize(filename(update_filename(answer)))
    end

    def filename(path)
      return sanitize(path) if path.nil?

      filename = sanitize(path).gsub(/&gt;/, '').gsub(/&lt;/, '').delete('>"[]{}*?:|]/<').delete('\\')

      if count.present? && count.positive?
        extname = File.extname(filename)
        basename = File.basename(filename, extname)

        filename = "#{basename}-(#{count})#{extname}"
        @count = nil # this is called multiple times for multiupload components so ensure we apply suffix to filename only once
      end

      filename
    end

    def update_filename(answer)
      jfif_or_jpg_extension?(answer) ? "#{File.basename(answer, '.*')}.jpeg" : answer
    end

    def jfif_or_jpg_extension?(answer)
      return false if answer.nil?

      file_extension = File.extname(answer)
      %w[.jfif .jpg].include?(file_extension)
    end

    # NOTE: Address component is different to other components in the sense it can
    # produce different validation errors in different fields, and we need to track
    # those errors between page renders, thus needing memoisation.
    def address_answer(component_id)
      @address_answer ||= {}

      @address_answer[component_id] ||= MetadataPresenter::AddressFieldset.new(
        answers.fetch(component_id, {})
      )
    end
  end
end
