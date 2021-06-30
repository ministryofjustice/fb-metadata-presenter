RSpec.describe MetadataPresenter::TraversedPages do
  subject(:traversed_pages) do
    described_class.new(
      service, user_data, current_page
    )
  end
  let(:service_metadata) { metadata_fixture(:branching) }

  describe '#all' do
    subject(:all) do
      traversed_pages.all
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
        expect(all.map(&:url)).to eq(
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
        expect(all.map(&:url)).to eq(
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
  end
end
