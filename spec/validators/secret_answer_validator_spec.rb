RSpec.describe SecretAnswerValidator do
  describe '#valid?' do
    let(:record) { MetadataPresenter::ResumeForm.new('What is your dog called?') }
    let(:recorded_answer) { 'Peanut' }

    context 'when is a matching answer' do
      [
        'Peanut',
        'peanut',
        ' peanut',
        ' peanut ',
        'Peanut ',
        ' Peanut ',
        ' Peanut'
      ].each do |valid_answer|
        it "returns valid for '#{valid_answer}'" do
          record.recorded_answer = recorded_answer
          record.secret_answer = valid_answer
          subject.validate(record)
          expect(record.errors).to be_empty
        end
      end
    end

    context 'when is not a matching answer' do
      [
        'not peanut',
        'P3anut',
        '"Peanut"'
      ].each do |invalid_answer|
        it "returns invalid for '#{invalid_answer}'" do
          record.recorded_answer = recorded_answer
          record.secret_answer = invalid_answer
          subject.validate(record)
          expect(record.errors.count).to eq(1)
        end
      end
    end
  end
end
