module MetadataPresenter
  class MultiUploadAnswer
    attr_accessor :previous_answers, :incoming_answer, :key

    def to_h
      {
        key => previous_answers_value.present? ? previous_answers_value.reject(&:blank?) : []
      }
    end

    def previous_answers_value
      if previous_answers.nil?
        return nil if incoming_answer.nil?

        [incoming_answer]
      elsif previous_answers.is_a?(Array)
        if incoming_answer.nil?
          return previous_answers.reject(&:blank?)
        end
        return previous_answers.reject(&:blank?) if previous_answers.find { |answer| answer['original_filename'] == incoming_answer['original_filename'] }.present?

        previous_answers.reject(&:blank?).push(incoming_answer)
      else
        if incoming_answer.nil?
          return [previous_answers]
        end

        [previous_answers, incoming_answer]
      end
    end

    def from_h(input)
      self.key = input.keys[0]
      self.previous_answers = input[key]
    end
  end
end
