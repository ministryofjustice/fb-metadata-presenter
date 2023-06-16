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
        # byebug
        x = multiupload_answer(component.id, count)
        return x.to_h if x.present?
      elsif component && component.type == 'checkboxes'
        answers[method_name.to_s].to_a
      else
        sanitize(answers[method_name.to_s])
      end
    end

    def upload_answer(component_id, _count)
      file_details = answers[component_id.to_s]

      return {} unless file_details
      if file_details.is_a?(Hash) || file_details.is_a?(ActionController::Parameters)
        file_details.merge('original_filename' => sanitize(filename(file_details['original_filename'])))
      else
        {
          'original_filename' => sanitize(filename(file_details.original_filename)),
          'content_type' => file_details.content_type,
          'tempfile' => file_details.tempfile.path.to_s
        }
      end
    end

    def multiupload_answer(component_id, _count)

      # showing page
      file_details = answers[component_id.to_s] unless answers.is_a?(MetadataPresenter::MultiUploadAnswer)
      return nil if file_details.nil? && answers.nil?
      if(file_details.is_a?(Hash))
        presentable = MetadataPresenter::MultiUploadAnswer.new
        presentable.key = component_id.to_s
        presentable.previous_answers = [file_details]
        return presentable
      end

      # return [] unless file_details
      # byebug
      # if(answers.is_a?(MetadataPresenter::MultiUploadAnswer))
      byebug
      if answers == {}
        return 
      end
      if answers.is_a?(Hash)
        if answers[component_id].is_a?(Array)
          answers[component_id].each { |answer| answer['original_filename'] = sanitize(filename(answer['original_filename'])) }
        end
        return answers
      end
      if answers.incoming_answer.present? && answers.incoming_answer.is_a?(ActionController::Parameters)
        # byebug
        answers.incoming_answer[component_id].original_filename = sanitize(filename(answers.incoming_answer[component_id].original_filename))
      end
      if answers.incoming_answer.present? && answers.incoming_answer[component_id].is_a?(ActionDispatch::Http::UploadedFile)
        x =  {
            'original_filename' => sanitize(filename(answers.incoming_answer[component_id].original_filename)),
            'content_type' => answers.incoming_answer[component_id].content_type,
            'tempfile' => answers.incoming_answer[component_id].tempfile.path.to_s
          }
        # previous_answers.is_a?(Hash) ? previous_answers = [previous_answers, x] : previous_answers.push(x)
        # byebug
        answers.incoming_answer = x
      end
      return answers

      # byebug
      # # if file details is array then we already have an answer
      # if(file_details.is_a?(ActionDispatch::Http::UploadedFile))
      #   # we have a file saved on disk
      #   result = []
      #   result.push(
      #     {
      #       'original_filename' => sanitize(filename(file_details.original_filename)),
      #       'content_type' => file_details.content_type,
      #       'tempfile' => file_details.tempfile.path.to_s
      #     }
      #   )
      #   return result
      # end
      # if(file_details.is_a?(ActionController::Parameters) || file_details.is_a?(Hash))
      #   # we have a new file in the incoming params
      #   result = []
      #   result.push(
      #     file_details.merge('original_filename' => sanitize(filename(file_details['original_filename'])))
      #   )
      #   return result
      # end
      # if existing answer, prepend the result with this
    
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

    private

    def filename(path)
      return sanitize(path) if path.nil?

      filename = sanitize(path).gsub(/&gt;/, '').gsub(/&lt;/, '').delete('>"[]{}*?:|]/<').delete('\\')

      if count.present? && count.positive?
        extname = File.extname(filename)
        basename = File.basename(filename, extname)

        filename = "#{basename}-(#{count})#{extname}"
      end

      filename
    end
  end
end
