module MetadataPresenter
  class DefaultText
    class << self
      delegate :[], :fetch, to: :defaults

      private

      def defaults
        Rails.application.config.default_text
      end
    end
  end
end
