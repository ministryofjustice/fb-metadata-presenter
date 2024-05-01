module MetadataPresenter
  module Summary
    class AnswersPresenter
      attr_reader :page_answers

      def initialize(page_answers)
        @page_answers = page_answers
      end

      def page
        @page ||= answers.first.page
      end

      def answers
        @answers ||= page_answers.select { |pa| pa.answer.present? }
      end

      def multi_questions_page?
        page.type.eql?('page.multiplequestions')
      end

      def to_partial_path
        'metadata_presenter/resume/answers_presenter'.freeze
      end
    end
  end
end
