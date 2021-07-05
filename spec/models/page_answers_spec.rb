RSpec.describe MetadataPresenter::PageAnswers do
  subject(:page_answers) { described_class.new(page, answers) }
  let(:page) { service.find_page_by_url('name') }

  describe '#validate_answers' do
    let(:answers) { {} }

    before do
      expect_any_instance_of(
        MetadataPresenter::ValidateAnswers
      ).to receive(:valid?).and_return(valid)
    end

    context 'when valid' do
      let(:valid) { true }

      it 'returns true' do
        expect(page_answers.validate_answers).to be_truthy
      end
    end

    context 'when invalid' do
      let(:valid) { false }

      it 'returns false' do
        expect(page_answers.validate_answers).to be_falsey
      end
    end
  end

  describe '#method_missing' do
    context 'when the components exist in a page' do
      context 'when there are answers' do
        let(:answers) { { 'name_text_1' => 'Mando' } }

        it 'returns the value of the answer' do
          expect(page_answers.name_text_1).to eq('Mando')
        end
      end

      context 'when there are no answers' do
        let(:answers) { {} }

        it 'returns nil' do
          expect(page_answers.name_text_1).to be_nil
        end
      end
    end

    context 'when there are upload answers' do
      let(:page) { service.find_page_by_url('dog-picture') }

      context 'when uploading a file' do
        let(:upload_file) do
          Rack::Test::UploadedFile.new(
            './spec/fixtures/computer_says_no.gif', 'image/gif'
          )
        end
        let(:answers) do
          { 'dog-picture_upload_1' => upload_file }
        end
        let(:expected_answer) do
          {
            'original_filename' => 'computer_says_no.gif',
            'content_type' => 'image/gif',
            'tempfile' => upload_file.path
          }
        end

        it 'returns file details hash' do
          expect(
            page_answers.send('dog-picture_upload_1')
          ).to include(expected_answer)
        end
      end

      context 'when check your answers page' do
        let(:upload) do
          {
            'original_filename' => 'computer_says_no.gif',
            'content_type' => 'image/gif'
          }
        end
        let(:answers) do
          {
            'dog-picture_upload_1' => upload
          }
        end

        it 'returns empty hash' do
          expect(
            page_answers.send('dog-picture_upload_1')
          ).to include(upload)
        end
      end

      context 'when not uploading a file' do
        let(:answers) do
          { 'dog-picture_upload_1' => nil }
        end

        it 'returns empty hash' do
          expect(
            page_answers.send('dog-picture_upload_1')
          ).to include({})
        end
      end
    end

    context 'when the components are optional' do
      let(:page) { service.find_page_by_url('burgers') }

      context 'checkboxes component' do
        let(:answers) { {} }

        it 'returns empty array' do
          expect(
            page_answers.send('burgers_checkboxes_1')
          ).to eq([])
        end
      end
    end

    context 'when sanitizing answers' do
      context 'when the answer should not be sanitised' do
        context 'when component type is text' do
          let(:answers) { { 'name_text_1' => 'script/' } }

          it 'returns the value of the answer' do
            expect(page_answers.name_text_1).to eq('script/')
          end
        end

        context 'when the component is a textarea' do
          let(:page) { service.find_page_by_url('family-hobbies') }
          let(:answers) { { 'hobbies_textarea_1' => 'Hiking, script/, eating muffins' } }

          it 'returns the value of the answer' do
            expect(page_answers.hobbies_textarea_1).to eq('Hiking, script/, eating muffins')
          end
        end

        context 'when the component type is date' do
          let(:page) { service.find_page_by_url('holiday') }
          let(:answers) { { 'holiday_date_1(3i)' => 'script/' } }

          it 'returns true' do
            expect(page_answers.holiday_date_1.day).to eq('script/')
          end
        end

        context 'when component type is upload' do
          let(:page) { service.find_page_by_url('dog-picture') }
          let(:upload_file) do
            Rack::Test::UploadedFile.new(
              './spec/fixtures/script.gif', 'image/gif'
            )
          end
          let(:answers) do
            { 'dog-picture_upload_1' => upload_file }
          end
          let(:expected_answer) do
            {
              'original_filename' => 'script.gif',
              'content_type' => 'image/gif',
              'tempfile' => upload_file.path
            }
          end

          it 'returns file details hash' do
            expect(
              page_answers.send('dog-picture_upload_1')
            ).to include(expected_answer)
          end
        end
      end

      context 'when the answer should be sanitized' do
        let(:script) { "<script>alert('bent coppers')</script>" }

        context 'when component type is text' do
          let(:answers) { { 'name_text_1' => script } }

          it 'sanitizes the answer' do
            expect(page_answers.name_text_1).to eq("alert('bent coppers')")
          end
        end

        context 'when the component is a textarea' do
          let(:page) { service.find_page_by_url('family-hobbies') }
          let(:answers) { { 'hobbies_textarea_1' => script } }

          it 'sanitizes the answer' do
            expect(page_answers.hobbies_textarea_1).to eq("alert('bent coppers')")
          end
        end

        context 'when the component type is date' do
          let(:page) { service.find_page_by_url('holiday') }
          let(:answers) { { 'holiday_date_1(3i)' => script } }

          it 'sanitizes the answer' do
            expect(page_answers.holiday_date_1.day).to eq("alert('bent coppers')")
          end
        end

        context 'when component type is upload' do
          let(:page) { service.find_page_by_url('dog-picture') }
          let(:upload_file) do
            Rack::Test::UploadedFile.new(
              './spec/fixtures/<img src=a onerror=alert(document.domain)>.txt', 'text/plain'
            )
          end
          let(:answers) do
            { 'dog-picture_upload_1' => upload_file }
          end

          it 'sanitizes file details hash' do
            expect(
              page_answers.send('dog-picture_upload_1')['original_filename']
            ).to eq('<img src="a">.txt')
          end
        end

        context 'when file details is a hash' do
          let(:page) { service.find_page_by_url('dog-picture') }
          let(:upload_file) do
            {
              'original_filename' => "<script>alert('upload')</script>.png",
              'content_type' => 'image/png',
              'tempfile' => '/var/folders/v1/qb4w33l97jz0zfpwhl7jd1k00000gn/T/RackMultipart20210706-23929-qfs5ct.png'
            }
          end
          let(:answers) do
            { 'dog-picture_upload_1' => upload_file }
          end

          it 'sanitizes file details hash' do
            expect(
              page_answers.send('dog-picture_upload_1')['original_filename']
            ).to eq("alert('upload').png")
          end
        end

        context 'when file details is an ActionController::Parameters object' do
          let(:page) { service.find_page_by_url('dog-picture') }
          let(:upload_file) do
            ActionController::Parameters.new(
              {
                'original_filename' => "<script>alert('upload')</script>.png",
                'content_type' => 'image/png',
                'tempfile' => '/var/folders/v1/qb4w33l97jz0zfpwhl7jd1k00000gn/T/RackMultipart20210706-23929-qfs5ct.png'
              }
            )
          end
          let(:answers) do
            { 'dog-picture_upload_1' => upload_file }
          end

          it 'sanitizes file details hash' do
            expect(
              page_answers.send('dog-picture_upload_1')['original_filename']
            ).to eq("alert('upload').png")
          end
        end
      end
    end
  end

  describe '#respond_to?' do
    context 'when there are answers' do
      context 'when answers contain dates' do
        let(:answers) { { 'name_text_1' => 'Mando' } }

        it 'returns true' do
          expect(page_answers.respond_to?(:name_text_1)).to be_truthy
        end
      end

      context 'when answers contain other components' do
        let(:page) { service.find_page_by_url('holiday') }
        let(:answers) { { 'holiday_date_1(3i)' => '2020' } }

        it 'returns true' do
          expect(page_answers.respond_to?(:holiday_date_1)).to be_truthy
        end
      end
    end

    context 'when there are no answers' do
      let(:answers) { {} }

      it 'returns true' do
        expect(page_answers.respond_to?(:name_text_1)).to be_truthy
      end
    end

    context 'when id does not exist in page metadata' do
      let(:answers) { {} }

      it 'returns falsey' do
        expect(page_answers.respond_to?(:omg_I_dont_exist)).to be_falsey
      end
    end
  end

  describe '#uploaded_files' do
    let(:answers) { {} }

    it 'returns empty array as default' do
      expect(page_answers.uploaded_files).to eq([])
    end
  end
end
