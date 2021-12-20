RSpec.describe MetadataPresenter::ColumnNumber do
  subject(:column_number) { described_class.new(attributes) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:attributes) do
    {
      uuid: uuid,
      coordinates: coordinates,
      new_column: new_column,
      service: service
    }
  end
  let(:uuid) { SecureRandom.uuid }
  let(:coordinates) { MetadataPresenter::Coordinates.new(service) }
  let(:latest_metadata) { metadata_fixture(:branching_10) }
  let(:positions) { {} }

  describe '#number' do
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(
        service.flow.keys.index_with { |_uuid| { row: nil, column: nil } }.merge(positions)
      )
    end

    context 'when no column has been set before' do
      let(:positions) do
        {
          uuid => {
            column: nil,
            row: nil
          }
        }
      end
      let(:new_column) { 1 }

      it 'returns the new column number' do
        expect(column_number.number).to eq(new_column)
      end
    end

    context 'when column number exists' do
      context 'when the new column is greater than the existing column' do
        let(:positions) do
          {
            uuid => {
              column: 1,
              row: 1
            }
          }
        end
        let(:new_column) { 10 }

        it 'returns the existing column number' do
          expect(column_number.number).to eq(1)
        end
      end

      context 'when the new column is not greater than the existing column' do
        let(:positions) do
          {
            uuid => {
              column: 10,
              row: 1
            }
          }
        end
        let(:new_column) { 1 }

        it 'returns the existing column number' do
          expect(column_number.number).to eq(10)
        end
      end

      context 'when checkanswers or confirmation page' do
        let(:new_column) { 10 }

        # branching fixture 10 CYA and Confirmation pages
        %w[da2576f9-7ddd-4316-b24b-103708139214 a88694da-8ded-44e7-bc89-e652c1a7f46d].each do |page_uuid|
          let(:uuid) { page_uuid }

          it 'returns the greater column number' do
            expect(column_number.number).to eq(new_column)
          end
        end
      end

      context 'when object is a branch' do
        let(:new_column) { 1 }
        let(:uuid) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # Branching Point 2

        it 'sets the column number for each branch spacer in the coordinates' do
          expect(coordinates).to receive(:set_branch_spacers_column).with(uuid, new_column).once
          column_number.number
        end
      end
    end
  end
end
