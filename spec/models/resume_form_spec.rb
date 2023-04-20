RSpec.describe MetadataPresenter::ResumeForm, type: :model do
  describe 'ResumeForm' do
    let (:secret_text) { 'Hello I am some text' }
    let (:recorded_answer) { 'Answer' }
    let (:record) { MetadataPresenter::ResumeForm.new(secret_text) }

    before do
      record.recorded_answer = recorded_answer
      record.secret_answer = ''
    end

    it 'should populate secret question text' do
      expect(record.secret_question).to eq(secret_text)
      expect(record.valid?).to eq(false)
    end

    it 'is valid if the secret question and answer are the same' do
      record.secret_answer = recorded_answer

      expect(record.valid?).to eq(true)
    end
  end
end
