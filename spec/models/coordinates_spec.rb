RSpec.describe MetadataPresenter::Coordinates do
  subject(:coordinates) { described_class.new(service) }
  let(:latest_metadata) { metadata_fixture(:branching_10) }
  let(:service) { MetadataPresenter::Service.new(latest_metadata) }
  let(:uuid) { 'ad011e6b-5926-42f8-8b7c-668558850c52' } # Page N

  describe '#set_column' do
    let(:new_column) { 1000 }

    it 'sets the supplied column number' do
      coordinates.set_column(uuid, new_column)
      expect(coordinates.uuid_column(uuid)).to eq(new_column)
    end
  end

  describe '#set_row' do
    let(:new_row) { 1000 }

    it 'sets the supplied row number' do
      coordinates.set_row(uuid, new_row)
      expect(coordinates.uuid_row(uuid)).to eq(new_row)
    end
  end

  describe '#uuid_column' do
    let(:expected_column) { 10 }
    let(:positions) do
      {
        uuid => {
          column: expected_column,
          row: 5
        }
      }
    end
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(positions)
    end

    it 'returns the column for the uuid' do
      expect(coordinates.uuid_column(uuid)).to eq(expected_column)
    end
  end

  describe '#uuid_row' do
    let(:expected_row) { 3 }
    let(:positions) do
      {
        uuid => {
          column: 10,
          row: expected_row
        }
      }
    end
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(positions)
    end

    it 'returns the row for the uuid' do
      expect(coordinates.uuid_row(uuid)).to eq(expected_row)
    end
  end

  describe '#uuid_at_position' do
    let(:positions) do
      {
        uuid => {
          column: 10,
          row: 2
        }
      }
    end
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(positions)
    end

    it 'returns the correct uuid at the column and row position' do
      expect(coordinates.uuid_at_position(10, 2)).to eq(uuid)
    end
  end

  describe '#positions_in_column' do
    let(:expected_column) do
      {
        '1234' => {
          column: 10,
          row: 2
        },
        '5678' => {
          column: 10,
          row: 3
        }
      }
    end
    let(:positions) { expected_column }
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(positions)

      it 'returns all the positions objects for a given column' do
        expect(coordinates.positions_in_column(10)).to eq(expected_column)
      end
    end
  end

  describe '#set_branch_spacers_column' do
    let(:uuid) { 'a02f7073-ba5a-459d-b6b9-abe548c933a6' } # Branching Point 2
    let(:positions) { { uuid => { row: nil, column: 10 } } }
    let(:expected_branch_spacers) do
      [
        {
          row: nil,
          column: 10
        },
        {
          row: nil,
          column: 10
        },
        {
          row: nil,
          column: 10
        }
      ]
    end
    before do
      allow_any_instance_of(MetadataPresenter::Coordinates).to receive(
        :setup_positions
      ).and_return(positions)
    end

    it 'sets the branch conditional spacers to be the same column number' do
      coordinates.set_branch_spacers_column(uuid, 10)
      expect(coordinates.branch_spacers[uuid]).to eq(expected_branch_spacers)
    end
  end

  describe '#set_branch_spacers_row' do
    let(:uuid) { '7fe9a893-384c-4e8a-bb94-b1ec4f6a24d1' } # Branching Point 4
    let(:positions) { { uuid => { row: 0, column: 10 } } }
    let(:expected_branch_spacers) do
      [
        {
          row: 0,
          column: nil
        },
        {
          row: 1,
          column: nil
        },
        {
          row: 2,
          column: nil
        },
        {
          row: 3,
          column: nil
        },
        {
          row: 4,
          column: nil
        }
      ]
    end

    it 'increments the row number for each consecutive branch spacer' do
      coordinates.set_branch_spacers_row(uuid, 0)
      expect(coordinates.branch_spacers[uuid]).to eq(expected_branch_spacers)
    end
  end
end
