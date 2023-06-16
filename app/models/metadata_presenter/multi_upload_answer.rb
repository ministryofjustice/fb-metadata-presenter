module MetadataPresenter
  class MultiUploadAnswer
    attr_accessor :previous_answers, :incoming_answer, :key

    def to_h
      # byebug
      {
        self.key => previous_answers_value
      }
    end

    def previous_answers_value
      if(self.previous_answers.nil?)
        return [self.incoming_answer]
      else
        if(self.previous_answers.is_a?(Array))
          if(self.incoming_answer.nil?)
            return self.previous_answers
          end
          return self.previous_answers.push(self.incoming_answer)
        else
          if(self.incoming_answer.nil?)
            return [self.previous_answers]
          end
          return [self.previous_answers, self.incoming_answer]
        end
      end
    end

    def from_h(input)
      self.key = input.keys[0]
      self.previous_answers = input[self.key]
    end
  end
end