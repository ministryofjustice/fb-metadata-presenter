module MetadataPresenter
  class Page < MetadataPresenter::Metadata
    include ActiveModel::Validations

    def validate_answers(answers)
      ValidateAnswers.new(page: self, answers: answers).valid?
    end

    def ==(other)
      id == other.id if other.respond_to? :id
    end

    def components
      metadata.components&.map do |component|
        MetadataPresenter::Component.new(component)
      end
    end

    def to_partial_path
      type.gsub('.', '/')
    end

    def template
      "metadata_presenter/#{type.gsub('.', '/')}"
    end
  end
end
