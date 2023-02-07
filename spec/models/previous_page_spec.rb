RSpec.describe MetadataPresenter::PreviousPage do
  subject(:previous_page) do
    described_class.new(
      service:,
      user_data:,
      current_page:,
      referrer:
    )
  end
  let(:user_data) { {} }
  let(:referrer) { '' }

  describe '#page' do
    context 'when using the old flow' do
      let(:service_metadata) { metadata_fixture(:version) }

      context 'when is a start page' do
        let(:current_page) { service.find_page_by_url('/') }

        it 'returns nil' do
          expect(previous_page.page).to be_nil
        end
      end

      context 'when it is the first page' do
        let(:current_page) { service.find_page_by_url('/name') }

        it 'returns the start page' do
          expect(previous_page.page).to eq(service.start_page)
        end
      end

      context 'when it is the second page' do
        let(:current_page) { service.find_page_by_url('/email-address') }

        it 'returns the first page' do
          expect(previous_page.page.url).to eq('name')
        end
      end

      context 'when is a confirmation page' do
        let(:current_page) { service.find_page_by_url('/confirmation') }

        it 'returns nil' do
          expect(previous_page.page).to be_nil
        end
      end
    end

    context 'when using the new branching flow' do
      let(:service_metadata) { metadata_fixture(:branching) }

      context 'when navigating the branch' do
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

        context 'when on start page' do
          let(:current_page) { service.find_page_by_url('/') }

          it 'returns nil' do
            expect(previous_page.page).to be_nil
          end
        end

        context 'when on first page' do
          let(:current_page) { service.find_page_by_url('/name') }

          it 'returns start page' do
            expect(previous_page.page).to eq(service.start_page)
          end
        end

        context 'when on page without branching previously' do
          let(:current_page) { service.find_page_by_url('do-you-like-star-wars') }

          it 'returns to the first page' do
            expect(previous_page.page.url).to eq('name')
          end
        end

        context 'when on page where it jump a branch previously' do
          let(:current_page) { service.find_page_by_url('favourite-fruit') }

          it 'returns to page before branch' do
            expect(previous_page.page.url).to eq('do-you-like-star-wars')
          end
        end

        context 'when on page where previously user were inside a branch' do
          let(:current_page) { service.find_page_by_url('favourite-band') }

          it 'returns to page inside the branch' do
            expect(previous_page.page.url).to eq('apple-juice')
          end
        end

        context 'when is a confirmation page' do
          let(:current_page) { service.find_page_by_url('confirmation') }

          it 'returns nil' do
            expect(previous_page.page).to be_nil
          end
        end
      end
    end
  end
end
