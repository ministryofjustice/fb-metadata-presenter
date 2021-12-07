RSpec.describe MetadataPresenter::RowNumber do
  subject(:row_number) { described_class.new(attributes) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:attributes) do
    {
      uuid: uuid,
      route: route,
      current_row: current_row,
      coordinates: coordinates,
      service: service
    }
  end
  let(:coordinates) { MetadataPresenter::Coordinates.new(service.flow) }
  let(:latest_metadata) { metadata_fixture(:branching_10) }
  let(:uuid) { SecureRandom.uuid }
  let(:route) { double(row: 2) }

  describe '#number' do
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(positions)
    end

    context 'when no row has been set before' do
      let(:positions) do
        {
          uuid => {
            column: 1,
            row: nil
          }
        }
      end

      context 'when the route starting row is the first row' do
        let(:route) { double(row: 0) }
        let(:current_row) { 1 }

        it 'returns the route row number' do
          expect(row_number.number).to eq(route.row)
        end
      end

      context 'when the route starting row is not the first row' do
        let(:route) { double(row: 2) }
        let(:current_row) { 5 }

        it 'returns the current_row number' do
          expect(row_number.number).to eq(current_row)
        end
      end
    end

    context 'when the object above the one being placed is a branch' do
      context 'current object is a branch' do
        let(:uuid) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # Branching Point 2
        let(:current_row) { 1 }
        let(:branching_point_5) { service.flow_object('19e4204d-672b-467e-9b8d-3a5cf22d9765') }
        let(:positions) do
          {
            branching_point_5.uuid => {
              column: 6,
              row: 0
            },
            uuid => {
              column: 6,
              row: nil
            }
          }
        end

        before do
          allow(row_number).to receive(:object_above).and_return(branching_point_5)
          allow_any_instance_of(MetadataPresenter::Coordinates).to receive(:uuid_row)
          allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
            :uuid_row
          ).with(branching_point_5.uuid).and_return(0)
        end

        it 'returns a row number leaving space for all the branch destinations above it' do
          expect(row_number.number).to eq(3)
        end
      end

      context 'current object is a page' do
        let(:uuid) { '64c0a3ef-53cb-47f4-b771-0c4b65496030' } # Page R
        let(:current_row) { 3 }
        let(:branching_point_4) { service.flow_object('7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1') }
        let(:positions) do
          {
            branching_point_4.uuid => {
              column: 9,
              row: 0
            },
            uuid => {
              column: 9,
              row: nil
            }
          }
        end

        before do
          allow(row_number).to receive(:object_above).and_return(branching_point_4)
          allow_any_instance_of(MetadataPresenter::Coordinates).to receive(:uuid_row)
          allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
            :uuid_row
          ).with(branching_point_4.uuid).and_return(0)
        end

        it 'returns a row number leaving space for all the branch destinations above it' do
          expect(row_number.number).to eq(5)
        end
      end
    end

    context 'when a branch destination is linked to later in the flow therefore has already been positioned' do
      let(:current_row) { 3 }
      let(:positions) do
        {
          uuid => {
            column: 10,
            row: 2
          }
        }
      end

      it 'returns the higher row number' do
        expect(row_number.number).to eq(3)
      end
    end

    context 'with checkanswers and confirmation pages' do
      let(:positions) { {} }
      let(:current_row) { 3 }

      context 'with checkanswers page' do
        let(:uuid) { 'da2576f9-7ddd-4316-b24b-103708139214' } # Check answers

        it 'always places them on row zero' do
          expect(row_number.number).to eq(0)
        end
      end

      context 'with confirmation page' do
        let(:uuid) { 'a88694da-8ded-44e7-bc89-e652c1a7f46d' } # Confirmation

        it 'always places them on row zero' do
          expect(row_number.number).to eq(0)
        end
      end
    end

    context 'objects previously placed on row zero' do
      let(:current_row) { 3 }
      let(:positions) do
        {
          uuid => {
            column: 5,
            row: 0
          }
        }
      end

      it 'leaves them on row zero' do
        expect(row_number.number).to eq(0)
      end
    end
  end
end
