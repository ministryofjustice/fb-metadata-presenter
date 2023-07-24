module MetadataPresenter
  class MultiUploadAnswer
    attr_accessor :previous_answers, :incoming_answer, :key

    def to_h
      {
        key => previous_answers_value.present? ? previous_answers_value.reject(&:blank?) : []
      }
    end

    def previous_answers_value
      return nil if previous_answers.nil? && incoming_answer.nil?
      return [incoming_answer] if previous_answers.nil? && incoming_answer.present?

      if previous_answers.is_a?(Array)
        return previous_answers.reject(&:blank?) if incoming_answer.nil? || previous_answers.find do |answer|
            answer['original_filename'] == incoming_answer['original_filename']
          end.present?

        previous_answers.reject(&:blank?).push(incoming_answer)
      else
        return [previous_answers] if incoming_answer.nil?
        [previous_answers, incoming_answer]
      end
    end

    def from_h(input)
      self.key = input.keys[0]
      self.previous_answers = input[key]
    end
  end
end
