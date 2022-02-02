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
  let(:coordinates) { MetadataPresenter::Coordinates.new(service) }
  let(:latest_metadata) { metadata_fixture(:branching_10) }
  let(:uuid) { SecureRandom.uuid }
  let(:route) { double(row: 2) }
  let(:branch_spacers) { {} }

  describe '#number' do
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(
        service.flow.keys.index_with { |_uuid| { row: nil, column: nil } }.merge(positions)
      )
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :branch_spacers
      ).and_return(branch_spacers)
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
        let(:branching_point_5) { '19e4204d-672b-467e-9b8d-3a5cf22d9765' }
        let(:route) { double(row: 1) }
        let(:current_row) { 1 }
        let(:positions) do
          {
            branching_point_5 => {
              column: 6,
              row: 0
            },
            uuid => {
              column: 6,
              row: nil
            }
          }
        end
        let(:branch_spacers) do
          {
            branching_point_5 => [
              { uuid: '007f4f35-8236-40cc-866c-cc2c27c33949', row: 0, column: 6 },
              { uuid: '7742dfcc-db2e-480b-9071-294fbe1769a2', row: 1, column: 6 },
              { uuid: 'da2576f9-7ddd-4316-b24b-103708139214', row: 2, column: 6 }
            ],
            uuid => [
              { uuid: '1314e473-9096-4434-8526-03a7b4b7b132', row: nil, column: 6 },
              { uuid: 'da2576f9-7ddd-4316-b24b-103708139214', row: nil, column: 6 },
              { uuid: '7742dfcc-db2e-480b-9071-294fbe1769a2', row: nil, column: 6 }
            ]
          }
        end

        it 'returns a row number leaving space for all the branch destinations above it' do
          expect(row_number.number).to eq(3)
        end
      end

      context 'current object is a page and branch is in the same column but more than one row above' do
        let(:uuid) { '64c0a3ef-53cb-47f4-b771-0c4b65496030' } # Page R
        let(:branching_point_4) { '7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1' }
        let(:positions) do
          {
            branching_point_4 => {
              column: 9,
              row: 0
            },
            uuid => {
              column: 9,
              row: nil
            }
          }
        end
        let(:branch_spacers) do
          {
            branching_point_4 => [
              { uuid: 'ced77b4d-efb5-4d07-b38b-2be9e09a73df', row: 0, column: 9 },
              { uuid: '46693db1-8995-4af0-a2d1-316140a5fb32', row: 1, column: 9 },
              { uuid: 'c01ae632-1533-4ee3-8828-a0c547200129', row: 2, column: 9 },
              { uuid: 'ad011e6b-5926-42f8-8b7c-668558850c52', row: 3, column: 9 },
              { uuid: 'da2576f9-7ddd-4316-b24b-103708139214', row: 4, column: 9 }
            ]
          }
        end

        context 'when current_row is less than the required space for expressions' do
          let(:route) { double(row: 3) }
          let(:current_row) { 3 }

          it 'returns a row number leaving space for all the branch destinations above it' do
            expect(row_number.number).to eq(5)
          end
        end

        context 'when current_row is already greater than the required space for expressions' do
          let(:route) { double(row: 6) }
          let(:current_row) { 6 }

          it 'returns a row number leaving space for all the branch destinations above it' do
            expect(row_number.number).to eq(6)
          end
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

      it 'returns the existing row number' do
        expect(row_number.number).to eq(2)
      end
    end

    context 'with more than one branch in a column' do
      let(:uuid) { '4cad5db1-bf68-4f7f-baf6-b2d48b342705' } # Branching Point 3
      let(:branching_point_5) { '19e4204d-672b-467e-9b8d-3a5cf22d9765' }
      let(:branching_point_2) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' }
      let(:route) { double(row: 2) }
      let(:current_row) { 2 }
      let(:positions) do
        {
          branching_point_5 => {
            column: 6,
            row: 0
          },
          branching_point_2 => {
            column: 6,
            row: 3
          },
          uuid => {
            column: 6,
            row: nil
          }
        }
      end
      let(:branch_spacers) do
        {
          branching_point_5 => [
            { uuid: '007f4f35-8236-40cc-866c-cc2c27c33949', row: 0, column: 6 },
            { uuid: '7742dfcc-db2e-480b-9071-294fbe1769a2', row: 1, column: 6 },
            { uuid: 'da2576f9-7ddd-4316-b24b-103708139214', row: 2, column: 6 }
          ],
          branching_point_2 => [
            { uuid: '1314e473-9096-4434-8526-03a7b4b7b132', row: 3, column: 6 },
            { uuid: 'da2576f9-7ddd-4316-b24b-103708139214', row: 4, column: 6 },
            { uuid: '7742dfcc-db2e-480b-9071-294fbe1769a2', row: 5, column: 6 }
          ],
          uuid => [
            { uuid: '79c18654-7ecb-43f9-bd7f-0b09eb9c075e', row: nil, column: 6 },
            { uuid: 'da2576f9-7ddd-4316-b24b-103708139214', row: nil, column: 6 }
          ]
        }
      end

      it 'finds the next available row leaving space for branch destinations above' do
        expect(row_number.number).to eq(6)
      end
    end

    context 'when the object is linked to in the previous column by a branch' do
      let(:latest_metadata) { metadata_fixture(:branching_8) }
      let(:uuid) { 'be130ac1-f33d-4845-807d-89b23b90d205' } # Page K
      let(:branching_point_2) { 'ffadeb22-063b-4e4f-9502-bd753c706b1d' }
      let(:page_f) { '957e523e-663f-4cc9-9e8a-36b15bcbcaec' }
      let(:route) { double(row: 1) }
      let(:current_row) { 1 }
      let(:positions) do
        {
          page_f => { row: 0, column: 6 }, # Page F
          branching_point_2 => { column: 6, row: 1 },
          uuid => { column: 7, row: nil }
        }
      end
      let(:branch_spacers) do
        {
          branching_point_2 => [
            { uuid: page_f, row: 0, column: 6 },
            { uuid: uuid, row: 2, column: 7 },
            { uuid: '3a584d15-6805-4a21-bc05-b61c3be47857', row: 3, column: 7 }
          ]
        }
      end

      it 'returns the row that was previously calculated for object' do
        expect(row_number.number).to eq(2)
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
