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

      context "when there are answers with special characters in 'text' component (?, &, /, <, > ')" do
        let(:answers) { { 'name_text_1' => " Text with special characters in it ?, &, /, <, > '" } }

        it 'returns the value of the answer' do
          expect(page_answers.name_text_1).to eq(" Text with special characters in it ?, &, /, <, > '")
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

    context 'when there are multiupload answers' do
      let(:page) { service.find_page_by_url('dog-picture-2') }

      context 'when uploading a file' do
        let(:upload_file) do
          ActionDispatch::Http::UploadedFile.new(tempfile: Rails.root.join('spec', 'fixtures', 'thats-not-a-knife.txt'), filename: 'thats-not-a-knife.txt', content_type: 'text/plain')
        end
        let(:multiupload_object) { MetadataPresenter::MultiUploadAnswer.new }
        let(:answers) { multiupload_object }
        let(:previous_answers) { nil }

        before do
          multiupload_object.key = 'dog-picture-2'
          multiupload_object.previous_answers = previous_answers
          multiupload_object.incoming_answer = { 'dog-picture-2' => upload_file }
        end

        it 'returns file details hash' do
          expect(
            # returned with a very different hash structure to single uploads in order to manage file list
            page_answers.send('dog-picture_upload_2')['dog-picture-2'].first['dog-picture-2'].original_filename
          ).to eq(upload_file.original_filename)
        end

        context 'when there are previous answers' do
          let(:previous_answers) do
            {
              'dog-picture-2' => { 'original_filename' => 'some_other_file.txt' }
            }
          end

          it 'adds the incoming and existing files to the same hash' do
            result = page_answers.send('dog-picture_upload_2')
            result.extend Hashie::Extensions::DeepFind

            # first values will contain previous files
            expect(
              result.deep_find('original_filename')
            ).to eq('some_other_file.txt')
            # last in the array should be the incoming file, still as a rack file
            expect(
              result['dog-picture-2'].last.values.first.original_filename
            ).to eq('thats-not-a-knife.txt')
          end

          context 'but no incoming answer' do
            let(:answers) do
              {
                'dog-picture_upload_2' => { 'original_filename' => 'just_existing_file.txt' }
              }
            end

            it 'returns a renderable hash of just existing files' do
              result = page_answers.send('dog-picture_upload_2')
              result.extend Hashie::Extensions::DeepFind

              expect(
                result.deep_find('original_filename')
              ).to eq('just_existing_file.txt')
            end
          end

          context 'when there are many previous answers' do
            let(:previous_answers) do
              {
                'dog-picture-2' => [{ 'original_filename' => 'even_more_files.txt' }, { 'original_filename' => 'yet_another.txt' }]
              }
            end

            it 'adds the incoming and existing files to the same hash' do
              result = page_answers.send('dog-picture_upload_2')
              result.extend Hashie::Extensions::DeepFind

              # first values will contain previous files
              expect(
                result.deep_find('original_filename')
              ).to eq('even_more_files.txt')
              # last in the array should be the incoming file, still as a rack file
              expect(
                result['dog-picture-2'].last.values.first.original_filename
              ).to eq('thats-not-a-knife.txt')
            end

            context 'but no incoming answer' do
              let(:answers) do
                {
                  'dog-picture_upload_2' => [{ 'original_filename' => 'even_more_files_this_time.txt' }, { 'original_filename' => 'yet_another.txt' }]
                }
              end

              it 'returns a renderable hash of just existing files' do
                result = page_answers.send('dog-picture_upload_2')

                result.extend Hashie::Extensions::DeepFind

                expect(
                  result.deep_find('original_filename')
                ).to eq('even_more_files_this_time.txt')
              end
            end
          end
        end
      end

      context 'when answers are nil' do
        let(:page) { service.find_page_by_url('dog-picture-2') }
        let(:answers) { { 'dog-picture_upload_2' => nil } }

        it 'returns nil' do
          expect(page_answers.send('dog-picture_upload_2')).to eq(nil)
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

          context "answer with special characters in textarea  e.g. (?, &, /, <, > ')" do
            let(:answers) { { 'hobbies_textarea_1' => " Hiking, script/, eating muffins, &, /, <, > '" } }

            it 'returns the value of the answer' do
              expect(page_answers.hobbies_textarea_1).to eq(" Hiking, script/, eating muffins, &, /, <, > '")
            end
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
          let(:answers) do
            { 'dog-picture_upload_1' => upload_file }
          end
          let(:expected_answer) do
            {
              'original_filename' => expected_filename,
              'content_type' => expected_mimetype,
              'tempfile' => upload_file.path
            }
          end

          context 'when filename should not be renamed' do
            let(:upload_file) do
              Rack::Test::UploadedFile.new(
                './spec/fixtures/script.gif', 'image/gif'
              )
            end
            let(:expected_filename) { 'script.gif' }
            let(:expected_mimetype) { 'image/gif' }

            it 'returns file details hash' do
              expect(
                page_answers.send('dog-picture_upload_1')
              ).to include(expected_answer)
            end
          end

          context 'when file extension should be renamed' do
            context 'when file extension is jfif' do
              let(:upload_file) do
                Rack::Test::UploadedFile.new(
                  './spec/fixtures/sample.jfif', 'image/jpeg'
                )
              end
              let(:expected_filename) { 'sample.jpeg' }
              let(:expected_mimetype) { 'image/jpeg' }

              it 'returns file details hash' do
                expect(
                  page_answers.send('dog-picture_upload_1')
                ).to include(expected_answer)
              end
            end

            context 'when file extension is jpg' do
              let(:upload_file) do
                Rack::Test::UploadedFile.new(
                  './spec/fixtures/quokka.jpg', 'image/jpeg'
                )
              end
              let(:expected_filename) { 'quokka.jpeg' }
              let(:expected_mimetype) { 'image/jpeg' }

              it 'returns file details hash' do
                expect(
                  page_answers.send('dog-picture_upload_1')
                ).to include(expected_answer)
              end
            end
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
            ).to eq('img src=a.txt')
          end

          context 'when file details is a hash' do
            let(:upload_file) do
              {
                'original_filename' => "<script>alert('upload')</script>.png",
                'content_type' => 'image/png',
                'tempfile' => '/var/folders/v1/qb4w33l97jz0zfpwhl7jd1k00000gn/T/RackMultipart20210706-23929-qfs5ct.png'
              }
            end

            it 'sanitizes file details hash' do
              expect(
                page_answers.send('dog-picture_upload_1')['original_filename']
              ).to eq("alert('upload').png")
            end

            it 'appends a suffix when there are previous uploads of the same filename' do
              subject.count = 1
              expect(
                page_answers.send('dog-picture_upload_1')['original_filename']
              ).to eq("alert('upload')-(1).png")
            end

            it 'appends a suffix based on previous matches' do
              subject.count = 2
              expect(
                page_answers.send('dog-picture_upload_1')['original_filename']
              ).to eq("alert('upload')-(2).png")
            end

            context 'when file contains forbidden characters' do
              let(:upload_file) do
                {
                  'original_filename' => 'hell\o"<>[]{}?/:|*.png',
                  'content_type' => 'image/png',
                  'tempfile' => '/var/folders/v1/qb4w33l97jz0zfpwhl7jd1k00000gn/T/RackMultipart20210706-23929-qfs5ct.png'
                }
              end

              it 'removes the forbidden characters' do
                expect(
                  page_answers.send('dog-picture_upload_1')['original_filename']
                ).to eq('hello.png')
              end
            end

            context 'when file extension is uncommon jpeg mime type' do
              let(:upload_file) do
                { 'original_filename' => 'test.JFIF' }
              end

              it 'replaces the extension and makes it lowercase' do
                expect(
                  page_answers.send('dog-picture_upload_1')['original_filename']
                ).to eq('test.jpeg')
              end
            end
          end

          context 'when file details is an ActionController::Parameters object' do
            let(:upload_file) do
              ActionController::Parameters.new(
                {
                  'original_filename' => "<script>alert('upload')</script>.png",
                  'content_type' => 'image/png',
                  'tempfile' => '/var/folders/v1/qb4w33l97jz0zfpwhl7jd1k00000gn/T/RackMultipart20210706-23929-qfs5ct.png'
                }
              )
            end

            it 'sanitizes file details hash' do
              expect(
                page_answers.send('dog-picture_upload_1')['original_filename']
              ).to eq("alert('upload').png")
            end

            context 'when file contains forbidden characters' do
              let(:upload_file) do
                ActionController::Parameters.new(
                  {
                    'original_filename' => 'hell\o"<>[]{}?/:|*.png',
                    'content_type' => 'image/png',
                    'tempfile' => '/var/folders/v1/qb4w33l97jz0zfpwhl7jd1k00000gn/T/RackMultipart20210706-23929-qfs5ct.png'
                  }
                )
              end

              it 'removes the forbidden characters' do
                expect(
                  page_answers.send('dog-picture_upload_1')['original_filename']
                ).to eq('hello.png')
              end
            end
          end
        end
      end
    end

    context 'when there are address components' do
      let(:answers) do
        {
          'address_address_1' =>
            { 'address_line_one' => 'test road',
              'address_line_two' => '',
              'city' => 'test city',
              'county' => '',
              'postcode' => 'test code',
              'country' => 'United Kingdom' }
        }
      end

      let(:component) { OpenStruct.new(id: 'address_address_1', name: 'address_address_1', type: 'address') }
      let(:components_collection) { [component] }

      before do
        allow(page_answers).to receive(:components).and_return(components_collection)
      end

      it 'returns the right keyword arguments of address' do
        address = page_answers.send('address_address_1')
        expect(address.address_line_one).to eq('test road')
        expect(address.address_line_two).to eq('')
        expect(address.city).to eq('test city')
        expect(address.county).to eq('')
        expect(address.postcode).to eq('test code')
        expect(address.country).to eq('United Kingdom')
      end

      context 'when address components has special characters' do
        let(:answers) do
          {
            'address_address_1' =>
              { 'address_line_one' => 'test road ?, &, /, <, >',
                'address_line_two' => '?, &, /, <, >',
                'city' => 'test city ?, &, /, <, >',
                'county' => '?, &, /, <, >',
                'postcode' => 'test code',
                'country' => 'United Kingdom' }
          }
        end

        it 'returns the right keyword arguments of address' do
          address = page_answers.send('address_address_1')
          expect(address.address_line_one).to eq('test road ?, &, /, <, >')
          expect(address.address_line_two).to eq('?, &, /, <, >')
          expect(address.city).to eq('test city ?, &, /, <, >')
          expect(address.county).to eq('?, &, /, <, >')
          expect(address.postcode).to eq('test code')
          expect(address.country).to eq('United Kingdom')
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
