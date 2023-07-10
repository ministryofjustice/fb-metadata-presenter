RSpec.describe MetadataPresenter::MultiUploadAnswer do
  subject(:multiupload_answer) { described_class.new }

  context '#to_h' do
    let(:key) { 'cool-dog-pictures' }

    before do
      subject.previous_answers = previous_answers
      subject.incoming_answer = incoming_answer
      subject.key = key
    end

    context 'no previous answers or incoming answers' do
      let(:previous_answers) { nil }
      let(:incoming_answer) { nil }

      it 'should return empty' do
        expect(subject.to_h).to eq({ key => [] })
      end

      context 'incoming answer is present' do
        let(:incoming_answer) { { 'original_filename' => 'a_new_file.txt' } }

        it 'should return new upload as part of an array' do
          expect(subject.to_h).to eq({ key => [incoming_answer] })
        end
      end
    end

    context 'single previous answer' do
      let(:previous_answers) { { 'original_filename' => 'file.txt' } }

      context 'incoming answer is nil' do
        let(:incoming_answer) { nil }

        it 'should return the previous answer as an array' do
          expect(subject.to_h).to eq({ key => [previous_answers] })
        end

        context 'previous answers somehow is only an empty hash' do
          let(:previous_answers) { {} }

          it 'should reject blank previous answers' do
            expect(subject.to_h).to eq({ key => [] })
          end
        end
      end

      context 'incoming answer is present' do
        let(:incoming_answer) { { 'original_filename' => 'another_file.txt' } }

        it 'should return the previous answer as an array with the incoming answer' do
          expect(subject.to_h).to eq({ key => [previous_answers, incoming_answer] })
        end

        context 'previous answers somehow is only an empty hash' do
          let(:previous_answers) { {} }

          it 'should reject blank previous answers' do
            expect(subject.to_h).to eq({ key => [incoming_answer] })
          end
        end
      end
    end

    context 'multiple previous answers' do
      let(:previous_answers) { [{ 'original_filename' => 'file.txt' }, { 'original_filename' => 'another_file.txt' }] }

      context 'incoming answer is nil' do
        let(:incoming_answer) { nil }

        it 'should return the previous answer as an array' do
          expect(subject.to_h).to eq({ key => previous_answers })
        end

        context 'previous answers somehow include an empty hash' do
          let(:previous_answers) { [{ 'original_filename' => 'file.txt' }, { 'original_filename' => 'another_file.txt' }, {}] }

          it 'should reject blank previous answers' do
            expect(subject.to_h).to eq({ key => [{ 'original_filename' => 'file.txt' }, { 'original_filename' => 'another_file.txt' }] })
          end
        end
      end

      context 'incoming answer is present' do
        let(:incoming_answer) { { 'original_filename' => 'yet_another_file.txt' } }

        it 'should return the previous answer as an array with the incoming answer' do
          expect(subject.to_h).to eq({ key => [previous_answers, incoming_answer].flatten })
        end

        context 'previous answers somehow is only an empty hash' do
          let(:previous_answers) { [{ 'original_filename' => 'file.txt' }, { 'original_filename' => 'another_file.txt' }, {}] }

          it 'should reject blank previous answers' do
            previous_answers.push({})

            expect(subject.to_h).to eq({ key => [{ 'original_filename' => 'file.txt' }, { 'original_filename' => 'another_file.txt' }, { 'original_filename' => 'yet_another_file.txt' }] })
          end
        end

        context 'incoming answer is a duplicate of a previous answer' do
          let(:incoming_answer) { { 'original_filename' => 'another_file.txt' } }

          it 'should not duplicate the answer in the returned set' do
            expect(subject.to_h).to eq({ key => previous_answers })
          end
        end
      end
    end
  end

  context '#from_h' do
    let(:input) do
      {
        'cool-files' => [
          { 'original_filename' => 'file.txt' },
          { 'original_filename' => 'another_file.txt' }
        ]
      }
    end

    before do
      subject.from_h(input)
    end

    it 'should set the key properly' do
      expect(subject.key).to eq('cool-files')
    end

    it 'should set the previous files from the array in the hash' do
      expect(subject.previous_answers).to eq(input['cool-files'])
    end
  end
end
