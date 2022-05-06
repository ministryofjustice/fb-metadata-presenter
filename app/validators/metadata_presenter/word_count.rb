module MetadataPresenter
  module WordCount
    def word_count(text)
      strip_tags(text).split.size
    end

    def strip_tags(text)
      strip_punctuation(ActionController::Base.helpers.strip_tags(text))
    end

    def strip_punctuation(text)
      text.gsub(/[^a-z0-9\s]/i, '')
    end
  end
end
