RSpec.describe MetadataPresenter::TraversedPages do
  subject(:traversed_pages) do
    described_class.new(
      service, user_data, current_page
    )
  end
  let(:service_metadata) do
    meta = metadata_fixture(:branching)
    meta['pages'] = meta['pages'].shuffle
    meta
  end

  describe '#all' do
    subject(:all) do
      traversed_pages.all.map(&:url)
    end

    context 'when current page is blank' do
      let(:current_page) { nil }

      context 'journey ends at the confirmation page' do
        let(:user_data) do
          {
            'name_text_1' => 'some name',
            'do-you-like-star-wars_radios_1' => 'Only on weekends',
            'star-wars-knowledge_text_1' => 'Know all about star wars',
            'star-wars-knowledge_radios_1' => 'Tony Stark',
            'favourite-fruit_radios_1' => 'Oranges',
            'orange-juice_radios_1' => 'No',
            'favourite-band_radios_1' => 'Beatles',
            'music-app_radios_1' => 'Spotify',
            'best-formbuilder_radios_1' => ' MoJ',
            'burgers_checkboxes_1' => ['Chicken, cheese, tomato'],
            'marvel-series_radios_1' => 'The Falcon and the Winter Soldier',
            'best-arnold-quote_checkboxes_1' => [
              'You are not you. You are me',
              'Get to the chopper',
              'You have been terminated'
            ]
          }
        end

        it 'returns all pages until last page based on user answers' do
          expect(all).to match_array(
            [
              '/',
              'name',
              'do-you-like-star-wars',
              'star-wars-knowledge',
              'favourite-fruit',
              'orange-juice',
              'favourite-band',
              'music-app',
              'best-formbuilder',
              'which-formbuilder',
              'burgers',
              'we-love-chickens',
              'marvel-series',
              'marvel-quotes',
              'best-arnold-quote',
              'arnold-right-answers',
              'check-answers',
              'confirmation'
            ]
          )
        end

        context 'journey ends with an exit page' do
          let(:service_metadata) do
            meta = metadata_fixture(:branching_7)
            meta['pages'] = meta['pages'].shuffle
            meta
          end
          let(:user_data) do
            {
              'page-b_text_1' => 'some text',
              'page-c_text_1' => 'some more text',
              'page-d_radios_1' => 'Item 3',
              'page-i_text_1' => 'even more text'
            }
          end

          it 'returns all pages until last page based on user answers' do
            expect(all).to match_array(
              [
                '/',
                'page-b',
                'page-c',
                'page-d',
                'page-i',
                'page-g'
              ]
            )
          end
        end
      end
    end

    context 'when current page is present' do
      let(:current_page) { service.find_page_by_url('name') }
      let(:user_data) { {} }

      it 'returns the pages up to the current page' do
        expect(all).to eq(['/'])
      end
    end

    context 'when there is no branching' do
      let(:user_data) { {} }
      let(:service_metadata) do
        meta = metadata_fixture(:version)
        meta['pages'] = meta['pages'].shuffle
        meta
      end

      context 'when current_page is present' do
        let(:current_page) { service.find_page_by_url('how-many-lights') }

        it 'returns all pages until current page using the default next' do
          expect(all).to match_array(
            [
              '/',
              'name',
              'email-address',
              'parent-name',
              'your-age',
              'family-hobbies',
              'do-you-like-star-wars',
              'holiday',
              'burgers',
              'star-wars-knowledge'
            ]
          )
        end

        context 'when current_page is not present' do
          let(:current_page) { nil }

          it 'returns all the pages up until there is no default next' do
            expect(all).to match_array(
              [
                '/',
                'name',
                'email-address',
                'parent-name',
                'your-age',
                'family-hobbies',
                'do-you-like-star-wars',
                'holiday',
                'burgers',
                'star-wars-knowledge',
                'how-many-lights',
                'dog-picture',
                'countries',
                'check-answers',
                'confirmation'
              ]
            )
          end
        end
      end
    end

    context 'when navigating only on main branch' do
      let(:current_page) { service.find_page_by_url('favourite-fruit') }

      let(:user_data) do
        {
          'name_text_1' => 'Rocket',
          'do-you-like-star-wars_radios_1' => 'Hell no!'
        }
      end

      it 'returns all pages traversed and answered' do
        expect(all).to eq(
          [
            '/',
            'name',
            'do-you-like-star-wars'
          ]
        )
      end
    end

    context 'when navigating only on branches' do
      let(:current_page) { service.find_page_by_url('burgers') }

      let(:user_data) do
        {
          'name_text_1' => 'Rocket',
          'do-you-like-star-wars_radios_1' => 'Hell no!',
          'favourite-fruit_radios_1' => 'Apples',
          'apple-juice_radios_1' => 'Yes',
          'favourite-band_radios_1' => 'Rolling Stones',
          'music-app_radios_1' => 'Spotify',
          'best-formbuilder_radios_1' => 'MoJ'
        }
      end

      it 'returns all pages traversed and answered' do
        expect(all).to eq(
          [
            '/',
            'name',
            'do-you-like-star-wars',
            'favourite-fruit',
            'apple-juice',
            'favourite-band',
            'music-app',
            'best-formbuilder'
          ]
        )
      end
    end

    context 'when there is an infinite looping flow (page pointing to itself)' do
      let(:service_metadata) do
        meta = metadata_fixture(:branching_11)
        meta['pages'] = meta['pages'].shuffle
        meta
      end
      let(:user_data) do
        {
          'page-b_text_1' => 'the',
          'page-c_text_1' => 'past',
          'page-d_radios_1' => 'Item 3',
          'page-i_text_1' => 'is a',
          'page-a_text_1' => 'foreign',
          'page-b_checkboxes_1' => ['Option 3'],
          'destinationb_checkboxes_1' => ['Option 3'],
          'page-j_checkboxes_1' => ['Option 1'],
          'page-k_text_1' => 'country',
          'page-e_text_1' => 'they',
          'page-f_checkboxes_1' => ['Option D'],
          'page-n_text_1' => 'do',
          'page-o_text_1' => 'things',
          'page-p_text_1' => 'differently',
          'page-d_text_1' => 'there'
        }
      end
      let(:current_page) { nil }

      it 'does not raise any errors' do
        expect { all }.to_not raise_error
      end

      it 'does not exceed the number of flow objects in the service' do
        expect(all.count).to be <= service.flow.count
      end
    end
  end
end
